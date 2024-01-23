//
//  CalendarEventsManager.swift
//  Time Bubbles
//
//  Created by Cristian Lapusan on 08.05.2021.
//1 runs on background Thread
//https://developer.apple.com/videos/play/wwdc2023/10052/

import EventKit
import CoreLocation
import SwiftUI
import CoreData
import MyPackage

extension CalendarManager {
    typealias Store = EKEventStore
}

// MARK: - essential methods
extension CalendarManager {
    var calendarAccessStatus:AccessStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
            case .authorized: return .granted
            case .denied: return .revoked
            case .notDetermined, .restricted: return .notRequested
            case .fullAccess: return .fullAccess
            case .writeOnly: return .writeOnly
            @unknown default: return .notRequested
        }
    }
    
    // MARK: - Public API
    ///if authorization granted, create default calendar to add events to it
    private func requestCalendarAccess(_ completion: @escaping () -> Void) {
        if calendarAccessStatus == .notRequested { //1. request access
            store.requestFullAccessToEvents { userGrantedAccess, _ in
                if userGrantedAccess {
                    //DispatchQueue.main.async { Secretary.shared.calendarAccessGranted = true } ⚠️
                    completion()
                }
            }
        } else { //2. access granted already
            completion()
        }
    }
    
    ///if user swipes on a bubble to enable calendar and bubble already has activity, all activity will be exported to Calendar App
    private func shouldEventifySessions(of bubble:Bubble?) { //bQueue
        guard
            let bubble = bubble,
            bubble.isCalendarEnabled,
            !bubble.sessions_.isEmpty else { return }
        
        bubble.sessions_.forEach {
            if !$0.isEnded && $0.temporaryEventID == nil {
                print("3/5 shouldEventify  ",bubble.sessions_.last?.pairs_.last)
                self.eventify(openSession: $0)
            }
            
            if $0.isEnded && $0.eventID == nil {
                self.eventify($0)
            }
        }
    }
    
    private func eventify(openSession: Session) {
        guard
            let bubble = openSession.bubble,
            bubble.isCalendarEnabled,
            calendarAccessStatus != .revoked,
            openSession.temporaryEventID == nil
        else { return }
        
        print("4/5 eventify.openSession.mainQ", bubble.sessions_.last?.pairs_.last)
        
        let bContext = PersistenceController.shared.bContext
        let objID = openSession.objectID
        
        guard let pairObjID = bubble.sessions_.last?.pairs_.first?.objectID else {
            return
        }
        
        bContext.perform {
            let bSession = PersistenceController.shared.grabObj(objID) as! Session
            let bPair = PersistenceController.shared.grabObj(pairObjID) as! Pair
            
            print("5/5 eventify.openSession.bQueue",bPair)
            
            //create and populate event
            let event = EKEvent(eventStore: self.store)
            
            event.title = self.eventTitle(for: bSession)
            
            //does not have endDate yet
            event.startDate = bPair.start
            event.endDate = bPair.start?.addingTimeInterval(15*60)
            
            event.notes = "⚠️ Temporary Event!\nIn Iventis App, touch and hold seconds to close session and update event"
            
            self.assignCalendar(to: event, bSession.bubble?.name)
            
            do {
                try self.store.save(event, span: .thisEvent, commit: true)
                bSession.temporaryEventID = event.eventIdentifier
                try? bSession.managedObjectContext?.save()
            }
            catch { print("event.save error", error) }
        }
    }
    
    func eventify(_ session: Session?) {
        guard calendarAccessStatus != .revoked else { return }
        guard let session = session, session.isEnded, !session.hasFinalEvent else { return }
        
        let objID = session.objectID
        var controller = PersistenceController.shared
        
        controller.bContext.perform {
            let bSession = controller.grabObj(objID) as! Session
            
            guard
                let firstPair = bSession.pairs_.first,
                let lastPair = bSession.pairs_.last
            else { return }
            
            let eventTitle = self.eventTitle(for: bSession)
            let eventNotes = self.eventNotes(from: [firstPair, lastPair])
            
            guard let eventStart = firstPair.start, let eventEnd = lastPair.pause else { return }
            
            let bubbleNote = bSession.bubble?.name
            
            //create a new calendar event
            self.newEvent(with: eventTitle,
                          bubbleName: bubbleNote,
                          eventNotes: eventNotes,
                          start: eventStart,
                          end: eventEnd,
                          bSession
            )
            
            delayExecution(.now() + 0.05) {
                controller.save(bSession.managedObjectContext)
            }
        }
    }
    
    ///updates event notes or  title
    func updateEvent(_ kind:EventUpdateKind) {
        
        switch kind {
            case .notes(let session):
                guard
                    let session = session,
                    let eventID = session.eventID ?? session.temporaryEventID,
                    let event = self.store.event(withIdentifier: eventID)                else { return }
                
                if let previousNotes = event.notes {
                    let userAdddedNotes = previousNotes.components(separatedBy: self.eventNotesSeparator).last!
                    
                    let notesAddedInTheApp = self.eventNotes(from: session.pairs_)
                    let updatedNotes = notesAddedInTheApp + userAdddedNotes
                    event.notes = updatedNotes
                    
                    event.title = self.eventTitle(for: session)
                    
                    try? self.store.save(event, span: .thisEvent, commit: true)
                }
                
            case .title(let bubble):
                bubble.sessions_.forEach {
                    guard
                        let id = $0.eventID ?? $0.temporaryEventID,
                        let event = self.store.event(withIdentifier: id)
                    else { return}
                    
                    event.title = self.eventTitle(for: $0)
                    
                    do { try self.store.save(event, span: .thisEvent, commit: true) }
                    catch { }
                }
        }
    }
    
    func deleteEvent(with id:String?) {
        guard
            let id = id,
            let event = store.event(withIdentifier: id)
        else { return }
        
        do { try store.remove(event, span: .thisEvent) }
        catch {
            print("deleteEvent failed")
        }
    }
    
    func shouldEventify(_ bubble:Bubble) {
        if bubble.isCalendarEnabled { bubbleToEventify = bubble }
    }
}

// MARK: -
class CalendarManager: NSObject {
    static let shared = CalendarManager()
    private override init() { super.init() }
    
    private func createDefaultCalendarIfNeeded(_ completion: @escaping () -> Void) {
        //it looks for calendars with title "Eventify" or similar
        //if it doesn't find calendar with "Time Bubbles" name it will attempt to create one
        //prefered calDAV or at least local
        
        //if default calendar found, return imediately
        for calendar in store.calendars(for: .event) {
            //if there is a calendar with that name already or similar name, do not create a calendar
            let calendarTitleContainsWord = calendar.title.lowercased().contains(defaultCalendarTitle.lowercased())
            
            if calendarTitleContainsWord {
                UserDefaults.shared.setValue(calendar.calendarIdentifier, forKey: UserDefaults.Key.defaultCalendarID)
                completion()
                return //end function without running the code below this line
            }
        }
        
        //------------------------------------------------------------
        //code below runs only if a calendar needs to be created
        
        //create calendar if nothing found
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = defaultCalendarTitle
        calendar.cgColor = defaultCalendarColor.cgColor
        
        //ideal situation, iCloud calendar that syncs with all devices
        let calDAVSources = store.sources.filter { $0.sourceType == .calDAV }
        let calDAVAvailable = !calDAVSources.isEmpty
        
        if calDAVAvailable {
            calendar.source = calDAVSources.first! //use calDAV source for the calendar
            
        }
        else {//use a local calendar source
            let localSources = store.sources.filter { $0.sourceType == .local }
            if !localSources.isEmpty { calendar.source = localSources.first! }
        }
        
        do {
            try store.saveCalendar(calendar, commit: true)
            UserDefaults.shared.setValue(calendar.calendarIdentifier, forKey: UserDefaults.Key.defaultCalendarID)
            completion()
        }
        catch { }
    }
    
    // MARK: -
    ///"Eventify" made up word :)). the bubble for which create events
    private(set) var  bubbleToEventify:Bubble? { didSet{
        if calendarAccessStatus == .notRequested {
            requestCalendarAccess { [weak self] in
                self?.createDefaultCalendarIfNeeded {
                    self?.shouldEventifySessions(of: self?.bubbleToEventify)
                }
            }
        } else { //access granted
            createDefaultCalendarIfNeeded { [weak self] in
                self?.shouldEventifySessions(of: self?.bubbleToEventify)
                print("2/5 bubbleToEventify  ", self?.bubbleToEventify?.sessions_.last?.pairs_.last)
            }
        }
    }}
    
    private lazy var store = Store() /* read write events */
    
    private let defaultCalendarTitle = "Iventis"
    private let defaultCalendarColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    private var defaultCalendarID:String? { UserDefaults.shared.value(forKey: UserDefaults.Key.defaultCalendarID) as? String }
    
    private let eventNotesSeparator = "Add notes below:\n"
    
    // MARK: - helpers
    private func dateInterval(_ start:Date?, _ end:Date?) -> String {
        guard let start = start else { return "date interval error" }
        
        let startDateString = DateFormatter.date.string(from: start)
        let endDateString = end == nil ? "[]" : DateFormatter.date.string(from: end!)
        let startAndEndAreTheSame = startDateString == endDateString
        return !startAndEndAreTheSame ? startDateString + " - " + endDateString : startDateString
    }
    
    private func timeInterval(_ start:Date?, _ end:Date?) -> String {
        guard let start = start else { return "time interval error" }
        
        let startTimeString = DateFormatter.time.string(from: start)
        let endTimeString = end == nil ? "[]" : DateFormatter.time.string(from: end!)
        
        return startTimeString + " - " + endTimeString
    }
    
    private func eventTitle(for session:Session) -> String {
        guard let bubble = session.bubble else { return "No Title" }
        
        let emoji = Color.emoji(for: bubble.color)
        let color = String.readableName(for: bubble.color)
        let bubbleName = bubble.note_.isEmpty ? color : bubble.note_
        
        let lapCount = String(session.pairs_.count)
        let laps = "・\(lapCount)"
        
        let allNotes = session.pairs_
            .compactMap(\.note)
            .filter { !$0.isEmpty }
        
        let lastNote = " " + (allNotes.last ?? "")
        
        return emoji + bubbleName + laps + lastNote
    }
    
    private func eventNotes(from pairs:[Pair]) -> String {
        let eventDuration = pairs.first?.session?.totalDuration
        let totalDuration = eventDuration?.timeComponentsAbreviatedString ?? ""
        let greaterThenSymbol = pairs.last?.pause == nil ? ">" : ""
        let string = String("Total \(greaterThenSymbol)\(totalDuration)\n-------------------\n")
        
        var bucket = String(string)
        
        for (index, pair) in pairs.reversed().enumerated() {
            let pairDuration = Float(pair.duration).timeComponentsAbreviatedString
            let pairNote = (!pair.note_.isEmpty ? pair.note_ : "")
            
            bucket += "\(pairs.count - index) ▪︎ \(pairDuration) \(pairNote)\n"
            
            //date interval
            bucket += dateInterval(pair.start, pair.pause)
            bucket += "\n"
            
            //time interval
            bucket += timeInterval(pair.start, pair.pause)
            bucket += "\n\n"
        }
        
        bucket += eventNotesSeparator
        return bucket
    } //1
    
    ///return an eventIdentifier
    private func newEvent(with title:String?,
                          bubbleName:String?,
                          eventNotes:String?,
                          start:Date,
                          end:Date,
                          _ session:Session) {
        
        let event = EKEvent(eventStore: store)
        
        event.title = title
        event.startDate = start
        event.endDate = end
        event.notes = eventNotes
        
        assignCalendar(to: event, bubbleName)
        
        do {
            try store.save(event, span: .thisEvent, commit: true)
            session.eventID = event.eventIdentifier
        }
        catch { print("store.save error", error) }
    }
    
    private func assignCalendar(to event:EKEvent, _ bubbleName:String?) {
        if let calendar = suggestedCalendar(for: bubbleName) {
            event.calendar = calendar
        }
        else {
            createDefaultCalendarIfNeeded { [weak self] in
                let calendar =
                self?.store.calendars(for: .event)
                    .filter{$0.calendarIdentifier == self?.defaultCalendarID}.first
                event.calendar = calendar
            }
        }
    }
    
    private func suggestedCalendar(for note:String?) -> EKCalendar? {
        guard let note = note else { return nil }
        
        let calendars = store.calendars(for: .event)
        let matchingCalendar = matchingCalendar(from: calendars, for: note)
        
        return matchingCalendar ?? defaultCalendar
    }
    
    private var defaultCalendar: EKCalendar? {
        store.calendars(for: .event).filter({$0.calendarIdentifier == defaultCalendarID}).first
    }
    
    ///ex: "Outdoor 🌳" matches "🌞 Outdoor"
    private func matchingCalendar(from calendars:[EKCalendar], for bubbleNote:String) -> EKCalendar? {
        var matchingCalendar:EKCalendar? = nil
        
        let bubbleNote_Scalars = Set(bubbleNote
            .lowercased()
            .unicodeScalars.filter { $0.value < 6000 && $0.value != 32 }
        )
        
        //⚠️ no idea why it's 6000 :)) I put an arbitrary value just to make sure all alphanumerics are included
        calendars.forEach {
            let calendarTitle_Scalars = Set($0.title
                .lowercased()
                .unicodeScalars.filter { $0.value < 6000 && $0.value != 32 }
            )
            
            if bubbleNote_Scalars == calendarTitle_Scalars { matchingCalendar = $0 }
        }
        
        return matchingCalendar
    }
    
    // MARK: - enums and structs
    enum EventUpdateKind {
        case title(_ bubble:Bubble)
        case notes(_ session:Session?)
    }
}

extension CalendarManager {
    enum AccessStatus {
        case notRequested
        case granted
        case revoked
        case fullAccess
        case writeOnly
    }
}

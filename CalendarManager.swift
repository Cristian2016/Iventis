//
//  CalendarEventsManager.swift
//  Time Bubbles
//
//  Created by Cristian Lapusan on 08.05.2021.
//1 runs on background Thread

import EventKit
import EventKitUI
import CoreLocation
import SwiftUI

extension CalendarManager {
    typealias EventStore = EKEventStore
}

// MARK: - essential methods
extension CalendarManager {
    // MARK: - Main
    ///if authorization granted, create default calendar to add events to it
    func requestCalendarAccess(_ completion: @escaping () -> Void) {
        if !calendarAccessGranted { //1. request access
            store.requestAccess(to: .event) { [weak self] userGrantedAccess, _ in
                if userGrantedAccess {
                    self?.calendarAccessGranted = true
                    completion()
                }
            }
        } else { //2. access granted already
            completion()
        }
    }
    
    ///⚠️ To avoid duplicates, this function creates a calendar only if
    ///there is no other calendar with same name or similar name.
    ///if it finds an existing calendar, it will set it as the default calendar
    private func createDefaultCalendarIfNeeded(_ completion: @escaping () -> Void) {
        //it looks for calendars with title "Fused" or similar
        //if it doesn't find calendar with "Time Bubbles" name it will attempt to create one
        //prefered calDAV or at least local
                
        //if default calendar found, return imediately
        for calendar in store.calendars(for: .event) {
            //if there is a calendar with that name already or similar name, do not create a calendar
            let calendarTitleContainsWord = calendar.title.lowercased().contains("fused")
            
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
    
    ///if user swipes on a bubble to enable calendar and bubble already has activity, all activity will be exported to Calendar App
    func createCalEventsForExistingSessions(of bubble:Bubble?) {
        //not viewContextBubble here
        guard
            let bubble = bubble,
            bubble.hasCalendar,
            !bubble.sessions_.isEmpty else { return }
                        
        let bContext = bubble.managedObjectContext //⚠️  it is already the backgroundContext
        
        bContext?.perform {
            bubble.sessions_.forEach { session in
                if session.isEnded && !session.isEventified {
                    self.createNewEvent(for: session)
                }
            }
            PersistenceController.shared.save(bContext)
        }
    }
    
    ///creates a new event when the user ends a session
    func createNewEvent(for session: Session?) {
        guard let session = session, session.isEnded, !session.isEventified else { return }
        
        let pairs = session.pairs_
        let firstPair = pairs.first!
        let lastPair = pairs.last!
        
        let notes = createEventNotes(from: pairs)
        
        let title = eventTitle(for: session)
        newEvent(with: title,
                 bubbleNote:session.bubble?.note,
                 eventNotes: notes,
                 start: firstPair.start!,
                 end: lastPair.pause!,
                 session
        )
        
        //since this method is called on bThread, make sure to save CoreData on mThread
        session.managedObjectContext?.perform {
            session.isEventified = true
            PersistenceController.shared.save(session.managedObjectContext!)
        }
    }
    
    ///updates event notes or event title
    func updateExistingEvent(_ kind:EventUpdateKind) {
        switch kind {
        case .notes(let session):
            guard
                let eventID = session.eventID,
                let event = store.event(withIdentifier: eventID),
                !session.pairs_.isEmpty
            else { return }
            
            if let previousNotes = event.notes {
                let notesAddedInCalendarByTheUser = previousNotes.components(separatedBy: eventNotesSeparator).last!
                let notesAddedInTheApp = createEventNotes(from: session.pairs_)
                let updatedNotes = notesAddedInTheApp + notesAddedInCalendarByTheUser
                
                // FIXME: find a better implementation
                //change event title here only if the latest note has changed as well
                event.title = eventTitle(for: session)
                event.notes = updatedNotes
                
                try? store.save(event, span: .thisEvent, commit: true)
            }
            
        case /* update event */.title(let bubble):
            bubble.sessions_.forEach {
                if
                    $0.isEnded,
                    let id = $0.eventID,
                    let event = store.event(withIdentifier: id) {
                    
                    event.title = eventTitle(for: $0)
                    do { try store.save(event, span: .thisEvent, commit: true) }
                    catch { }
                }
            }
        }
    }
}

// MARK: -
class CalendarManager: NSObject {
    static let shared = CalendarManager()
    private override init() {
        super.init()
        
    }
    
    // MARK: -
    private var calendarAccessGranted: Bool {
        get {
            let key = UserDefaults.Key.calendarAccessGranted
            return UserDefaults.standard.value(forKey: key) != nil
        }
        
        set {
            let key = UserDefaults.Key.calendarAccessGranted
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    ///"Eventify" made up word :)). the bubble for which create events
    var bubbleToEventify:Bubble? {didSet{
        if !calendarAccessGranted { //access not granted yet
            requestCalendarAccess { [weak self] in //mThread closure
                self?.createDefaultCalendarIfNeeded {
                    self?.createCalEventsForExistingSessions(of: self?.bubbleToEventify)
                }
            }
        } else { //access granted already
            createDefaultCalendarIfNeeded { [weak self] in
                self?.createCalEventsForExistingSessions(of: self?.bubbleToEventify)
            }
        }
    }}
    
    private lazy var store = EventStore() /* read write events */
    
    private let defaultCalendarTitle = "Fused 📥"
    private let defaultCalendarColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    private var defaultCalendarID:String? { UserDefaults.shared.value(forKey: UserDefaults.Key.defaultCalendarID) as? String }
    
    private let eventNotesSeparator = "Add notes below:\n"
    
    // MARK: - Events
    //could this cause memory cycle?? ⚠️
    private func lastSubeventNote(for session:Session) -> String {
        session.bubble?.lastPair?.note ?? ""
    }
    
    // MARK: - Main
    func deleteEvent(with id:String?) {
        guard
            let id = id,
            let event = store.event(withIdentifier: id)
        else { return }
        
        do { try store.remove(event, span: .thisEvent) }
        catch { }
    }
    
    func addNote(_ note:String, to event:EKEvent) {
        event.notes = note
    }
    
    // MARK: - helpers
    private func dateInterval(start:Date, end:Date) -> String {
        let startDateString = DateFormatter.date.string(from: start)
        let endDateString = DateFormatter.date.string(from: end)
        let startAndEndAreTheSame = startDateString == endDateString
        return !startAndEndAreTheSame ? startDateString + " - " + endDateString : startDateString
    }
    
    private func timeInterval(start:Date, end:Date) -> String {
        let startTimeString = DateFormatter.time.string(from: start)
        let endTimeString = DateFormatter.time.string(from: end)
        
        return startTimeString + " - " + endTimeString
    }
    
    private func createEventNotes(from pairs:[Pair]) -> String {
        let eventDuration = pairs.first?.session?.totalDuration
        let totalDuration = eventDuration?.timeComponentsAbreviatedString ?? ""
        let string = String("Total \(totalDuration)\n-------------------\n")
        
        var bucket = String(string)
        
        for (index, pair) in pairs.enumerated() {
            let pairDuration = Float(pair.duration).timeComponentsAbreviatedString
            let pairNote = (!pair.note_.isEmpty ? pair.note_ : "")
            
            bucket += "\(index + 1) ▪︎ \(pairDuration) \(pairNote)\n"
            
            //date interval
            bucket += dateInterval(start: pair.start!, end: pair.pause!)
            bucket += "\n"
            
            //time interval
            bucket += timeInterval(start: pair.start!, end: pair.pause!)
            bucket += "\n\n"
        }
        
        bucket += eventNotesSeparator
        return bucket
    } //1
    
    ///return an eventIdentifier
    private func newEvent(with title:String?, bubbleNote:String?, eventNotes:String?, start:Date, end:Date, _ session:Session) {
        
        let event = EKEvent(eventStore: store)
        
        event.title = title
        event.startDate = start
        event.endDate = end
        event.notes = eventNotes
        
        if let calendar = suggestedCalendar(for: bubbleNote) { event.calendar = calendar }
        else {//create Calendar if you can't find one
            createDefaultCalendarIfNeeded { [weak self] in
                let calendar =
                self?.store.calendars(for: .event)
                    .filter({$0.calendarIdentifier == self?.defaultCalendarID}).first
                event.calendar = calendar
            }
        }
        
        do {
            try store.save(event, span: .thisEvent, commit: true)
            session.eventID = event.eventIdentifier
        }
        catch { print("store.save error", error) }
    }
    
    private func eventTitle(for session:Session) -> String {
        //bNote bubbleNote
        //emojiSquare 🟪
        //pCount pairsCount
        guard let bubble = session.bubble else { return "No Title" }
        
        let friendlyBubbleColorName = Color.userFriendlyBubbleColorName(for: bubble.color)
        let emojiSquare = Color.emoji(for: bubble.color ?? "mint")
        let bNote = bubble.note_.isEmpty ? friendlyBubbleColorName : bubble.note_
        
        let pairsCount = String(session.pairs_.count)
        let lastPairNote = " " + session.pairs_.last!.note_
        
        let pCount = (pairsCount != "1") ? "・\(pairsCount)" : ""
        let eventTitle = emojiSquare + bNote + lastPairNote + pCount
        
        return eventTitle
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
    
    ///Calendar name to match with bubble name.
    ///ex: "Outdoor 🌳" matches "🌞 Outdoor"
    ///for each calendar in calendars, compare calendar.title with bubble.note
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
        case notes(_ session:Session)
    }
}

extension CalendarManager {
    
}

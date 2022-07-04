//
//  CalendarEventsManager.swift
//  Time Bubbles
//
//  Created by Cristian Lapusan on 08.05.2021.
//

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
    func requestAuthorizationAndCreateCalendar() {
        if EventStore.authorizationStatus(for: .event) == .authorized { return }
        
        store.requestAccess(to: .event) {//not main thread
            [weak self] /* access */ userGrantedAccess, error in
            guard let self = self else {return}
            if userGrantedAccess { self.createCalendarIfNeeded(with: self.defaultCalendarTitle) }
        }
    }
    
    ///⚠️ To avoid duplicates, this function creates a calendar only if
    ///there is no other calendar with same name or similar name.
    ///if it finds an existing calendar, it will set it as the default calendar
    private func createCalendarIfNeeded(with title:String) {
        //it looks for calendars with "Time Bubbles" or similar name
        //if it doesn't find calendar with "Time Bubbles" name it will attempt to create one
        //prefered calDAV or at least local
        
        if doNotCreateCalendar { return }
        
        store.calendars(for: .event).forEach {
            //if there is a calendar with that name already or similar name, do not create a calendar
            let condition0 = $0.title == defaultCalendarTitle
            let condition1 = $0.title.lowercased().contains("time") && $0.title.lowercased().contains("bubble")
            
            if condition0 || condition1 {
                UserDefaults.shared.setValue($0.calendarIdentifier, forKey: UserDefaults.Key.defaultCalendarIdentifier)
                doNotCreateCalendar = true
                return //early exit from the for loop
            }
        }
        
        //calendar creation
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = defaultCalendarTitle
        calendar.cgColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1).cgColor
        
        //ideal situation, iCloud calendar that syncs with all devices
        let calDAVSources = store.sources.filter { $0.sourceType == .calDAV }
        let calDAVAvailable = !calDAVSources.isEmpty
        
        if calDAVAvailable {
            calendar.source = calDAVSources.first! //use calDAV source for the calendar
            
        } else {//try to use a local source for the calendar
            
            let localSources = store.sources.filter { $0.sourceType == .local }
            if !localSources.isEmpty { calendar.source = localSources.first! }
        }
        
        do {
            try store.saveCalendar(calendar, commit: true)
            UserDefaults.shared.setValue(calendar.calendarIdentifier, forKey: UserDefaults.Key.defaultCalendarIdentifier)
        }
        catch { }
    }
    
    // MARK: -
    ///if user swipes on a bubble to enable calendar and bubble already has activity, all activity will be exported to Calendar App
    func shouldExportToCalendarAllSessions(of bubble:Bubble) {
        guard
            bubble.hasCalendar,
            !bubble.sessions_.isEmpty else { return }
                
        DispatchQueue.global().async { [weak self] in
            bubble.sessions_.forEach { session in
                if session.isEnded { self?.createNewEvent(for: session) }
            }
        }
    }
    
    ///creates a new event when the user ends a session
    func createNewEvent(for session: Session?) {
        guard
            let session = session,
            session.isEnded,
            session.eventID == nil else { return }
                
        let pairs = session.pairs_
        let firstPair = pairs.first!
        let lastPair = pairs.last!
        
        let notes = composeEventNotes(from: pairs)
        
        let title = title(for: session)
        session.eventID = newEvent(with: title,
                                   bubbleNote:session.bubble?.note,
                                   eventNotes: notes,
                                   start: firstPair.start!,
                                   end: lastPair.pause!)
        PersistenceController.shared.save()
    }
}

// MARK: -
class CalendarManager: NSObject {
    private lazy var store = EventStore() /* read write events */
    
    private(set) var defaultCalendarTitle = "Time Bubbles 📥"
    private let eventNotesSeparator = "Add notes below:\n"
    private lazy var defaultCalendarID = UserDefaults.shared.value(forKey: UserDefaults.Key.defaultCalendarIdentifier) as? String
    
    // MARK: - public
    private var doNotCreateCalendar = false
    
    // MARK: - Events
    //could this cause memory cycle?? ⚠️
    private func lastSubeventNote(for session:Session) -> String {
        session.bubble?.lastPair?.note ?? ""
    }
    
    // MARK: - Main
    
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
                let notesAddedInTheApp = composeEventNotes(from: session.pairs_)
                let updatedNotes = notesAddedInTheApp + notesAddedInCalendarByTheUser
                
                // FIXME: find a better implementation
                //change event title here only if the latest note has changed as well
                event.title = title(for: session)
                event.notes = updatedNotes
                
                do { try store.save(event, span: .thisEvent, commit: true) }
                catch { }
            }
            
        case /* update event */.title(let bubble):
            bubble.sessions_.forEach {
                if
                    $0.isEnded,
                    let id = $0.eventID,
                    let event = store.event(withIdentifier: id) {
                    
                    event.title = title(for: $0)
                    do { try store.save(event, span: .thisEvent, commit: true) }
                    catch { }
                }
            }
        }
    }
    
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
    
    // MARK: - new feature
    func newQuickActionEvent() {
        
        let event = EKEvent(eventStore: store)
        event.title = "Quick Action Event"
        
        //set event duration to 15 min
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(60*15)
        
        let defaultCalendarIdentifier = UserDefaults.shared.value(forKey: UserDefaults.Key.defaultCalendarIdentifier) as? String
        
        if let calendar = store.calendars(for: .event).filter({$0.calendarIdentifier == defaultCalendarIdentifier}).first {
            event.calendar = calendar
        }
        else {
            createCalendarIfNeeded(with: defaultCalendarTitle)
            delayExecution(.now() + 2.0) {[weak self] in
                let calendar = self?.store.calendars(for: .event).filter({$0.calendarIdentifier == defaultCalendarIdentifier}).first
                event.calendar = calendar
            }
        }
        event.alarms = []
        
        do {
            try store.save(event, span: .thisEvent, commit: true)
        }
        catch let error {
            print(error.localizedDescription)
            return
        }
    }
    
    // MARK: - helpers
    private func dateInterval(start:Date, end:Date) -> String {
        let startDateString = DateFormatter.bubbleStyleDate.string(from: start)
        let endDateString = DateFormatter.bubbleStyleDate.string(from: end)
        let startAndEndAreTheSame = startDateString == endDateString
        return !startAndEndAreTheSame ? startDateString + " - " + endDateString : startDateString
    }
    
    private func timeInterval(start:Date, end:Date) -> String {
        let startTimeString = DateFormatter.bubbleStyleTime.string(from: start)
        let endTimeString = DateFormatter.bubbleStyleTime.string(from: end)
        
        return startTimeString + " - " + endTimeString
    }
    
    private func composeEventNotes(from pairs:[Pair]) -> String {
        var bucket = String()
        for (index, pair) in pairs.enumerated() {
            let note = (!pair.note_.isEmpty ? pair.note_ : "Untitled")
            bucket += "◼︎ \(index + 1). " + note + "\n"
            
            //date interval
            bucket += dateInterval(start: pair.start!, end: pair.pause!)
            bucket += "\n"
            
            //time interval
            bucket += timeInterval(start: pair.start!, end: pair.pause!)
            bucket += "\n"
            
            //duration
            let stringDuration = Float(pair.duration).timeComponentsAbreviatedString
            bucket += "Duration " + stringDuration
            bucket += "\n" + "\n"
        }
        
        bucket += eventNotesSeparator
        return bucket
    }
    
    private func newEvent(with title:String?, bubbleNote:String?, eventNotes:String?, start:Date, end:Date) -> String? {
        
        let event = EKEvent(eventStore: store)
        
        event.title = title
        event.startDate = start
        event.endDate = end
        event.notes = eventNotes
        
        if let calendar = suggestedCalendar(for: bubbleNote) { event.calendar = calendar }
        else {//create Calendar if you can't find one
            createCalendarIfNeeded(with: defaultCalendarTitle)
            delayExecution(.now() + 2.0) {[weak self] in
                let calendar = self?.store.calendars(for: .event).filter({$0.calendarIdentifier == self?.defaultCalendarID}).first
                event.calendar = calendar
            }
        }
        
        event.alarms = []
        
        do {
            try store.save(event, span: .thisEvent, commit: true)
            return event.eventIdentifier
        }
        catch { return nil }
    }
    
    private func title(for session:Session) -> String {
        guard let bubble = session.bubble else { return "No Title" }
        
        let friendlyBubbleColorName = Color.userFriendlyBubbleColorName(for: bubble.color)
        let note = bubble.note_.isEmpty ? friendlyBubbleColorName : bubble.note_
        let colorEmoji = Color.emoji(for: bubble.color ?? "mint")
        
        let symbol:String
        switch bubble.kind {
        case .stopwatch: symbol = colorEmoji
        case .timer(limit: _): symbol = colorEmoji
        }
        
        let subeventsCount = String(session.pairs_.count)
        let latestSubeventTitle = " " + session.pairs_.last!.note_
        
        let count = (subeventsCount != "1") ? "・\(subeventsCount)" : ""
        let eventTitle = symbol + note + latestSubeventTitle + count
        
        return eventTitle
    }
    
    private func isEventStillInTheCalendar(_ eventID:String) -> Bool {
        return false
    }
    
    // MARK: - helpers
    ///if stickynote matches a calendar already present in the Calendar App
    private func suggestedCalendar(for note:String?) -> EKCalendar? {
        guard let note = note else { return nil }
        
        let calendars = store.calendars(for: .event)
        let matchingCalendar = getMatchingCalendar(from: calendars, for: note)
        
        return matchingCalendar ?? defaultCalendar
    }
    
    private var defaultCalendar: EKCalendar? {
        store.calendars(for: .event).filter({$0.calendarIdentifier == defaultCalendarID}).first
    }
    
    ///Calendar name to match with bubble name.
    ///ex: "Outdoor 🌳" matches "🌞 Outdoor"
    private func getMatchingCalendar(from calendars:[EKCalendar], for bubbleNote:String) -> EKCalendar? {
        var matchingCalendar:EKCalendar? = nil
        
        let set0 = Set(bubbleNote.lowercased().unicodeScalars.filter { $0.value < 6000 && $0.value != 32 })
        
        //⚠️ no idea why it's 6000 :)) I put an arbitrary value just to make sure all alphanumerics are included
        calendars.forEach { calendar in
            let set1 = Set(calendar.title.lowercased().unicodeScalars.filter { $0.value < 6000 && $0.value != 32 })
            if set0 == set1 { matchingCalendar = calendar }
        }
        
        return matchingCalendar
    }
    
    // MARK: -
    static let shared = CalendarManager()
    private override init() {
        super.init()
    }
    
    // MARK: - enums and structs
    enum EventUpdateKind {
        case title(_ bubble:Bubble)
        case notes(_ session:Session)
    }
}

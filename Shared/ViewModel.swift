//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//  CoreData constraints https://www.youtube.com/watch?v=NZIlmRSB8l8
//1 Add Tag and Undo Start. User can undo start or tag activity within 5 seconds after starting the bubble
//1 make sure to set fiveSeconds_bRank to nil first, then set it to a new value

import Foundation
import SwiftUI
import Combine
import CoreData
import MyPackage

class ViewModel: ObservableObject {
    private let secretary = Secretary.shared
            
    deinit { NotificationCenter.default.removeObserver(self) } //1
    
    // MARK: - Alerts
    @Published var path = [Bubble]()
            
    // MARK: -
    var notesForPair: CurrentValueSubject<Pair?, Never> = .init(nil)
    
    var notesForBubble: CurrentValueSubject<Bubble?, Never> = .init(nil)
        
    // MARK: -
    private func updateTimeComponents(_ bubbles: [Bubble]?) {
        DispatchQueue.global().async {
            bubbles?.forEach { bubble in
                let components = bubble.initialClock.timeComponentsAsStrings
            
                DispatchQueue.main.async {
                    bubble.coordinator.hrPublisher.send(components.hr)
                    bubble.coordinator.minPublisher.send(components.min)
                    bubble.coordinator.secPublisher.send(components.sec)
                }
            }
        }            
    }
    
    ///wakeUp only for running bubbles
    func wakeUpCoordinator(of bubble:Bubble) {
        guard bubble.state == .running else {
            bubble.coordinator
            return
        }
        DispatchQueue.global().async { bubble.coordinator.update(.start) }
    }
         
    // MARK: - background Timers
    private lazy var bubbleTimer = BubbleTimer()
    
    func bubbleTimer(_ action:BubbleTimer.Action) {
        switch action {
            case .start: bubbleTimer.perform(.start)
            case .pause: bubbleTimer.perform(.pause)
        }
    }
    
    // MARK: - User Intents
    //from PaletteView and...
    func createBubble(_ kind:Bubble.Kind, _ color:String, _ note:String? = nil) {
        
        let context = PersistenceController.shared.container.newBackgroundContext()
                
        context.perform {
            let newBubble = Bubble(context: context)
            newBubble.created = Date()
            newBubble.kind = kind
            switch kind {
                case .timer(let initialClock):
                    newBubble.initialClock = initialClock
                default: newBubble.initialClock = 0
            }
            
            newBubble.color = color
            newBubble.rank = Int64(UserDefaults.generateRank())
            
            let sdb = StartDelayBubble(context: newBubble.managedObjectContext!)
            newBubble.sdb = sdb
            if let note = note {
                newBubble.note_ = note
                newBubble.isNoteHidden = false
            }
            
            try? context.save()
        }
    }
    
    func delete(_ bubble:Bubble) {
        //if unpinned are hidden & bubble to delete is pinned and pinned section has only one item, unhide unpinned
//        if secretary.showFavoritesOnly, Secretary.shared.pinnedBubblesCount == 1 {
//            secretary.showFavoritesOnly = false
//        }
        
        bubble.coordinator.update(.pause)
        if !path.isEmpty { path = [] }
        
        let context = bubble.managedObjectContext!
        
        //⚠️ do I really need to set to nil?
        delayExecution(.now() + 0.2) { bubble.coordinator = nil  }

        context.perform {
            context.delete(bubble)
            try? context.save()
        }
    }
    
    func deleteSession(_ session:Session) {
        guard let bubble = session.bubble else { fatalError() }
        if bubble.lastSession == session {
            bubble.syncSmallBubbleCell = false
            
            //reset bubble clock
            bubble.currentClock = bubble.initialClock
            bubble.coordinator.componentsPublisher.send(bubble.initialClock.timeComponentsAsStrings)
        }
        
        let viewContext = PersistenceController.shared.viewContext
        viewContext.delete(session)
        try? viewContext.save()
    }
    
    func removeAddNoteButton(_ bubble:Bubble) {
        if let bubbleRank = secretary.addNoteButton_bRank, bubbleRank == Int(bubble.rank) {
            secretary.addNoteButton_bRank = nil
        }
    }
    
    func deletePair(_ pair:Pair?) {
        guard let pair = pair else { return }
        let viewContext = PersistenceController.shared.viewContext
        viewContext.delete(pair)
        try? viewContext.save()
    }
    
    ///delete all sessions and pairs and make it brandNew
    func reset(_ bubble:Bubble) {
        guard !bubble.sessions_.isEmpty else { return }
        
        let viewContext = PersistenceController.shared.viewContext
        bubble.created = Date()
        bubble.currentClock = bubble.initialClock
        bubble.coordinator.componentsPublisher.send(bubble.initialClock.timeComponentsAsStrings)
        bubble.sessions?.forEach { viewContext.delete($0 as! Session) }
        try? viewContext.save()
        
        bubble.coordinator.update(.pause)
        updateTimeComponents([bubble])
    }
    
    func togglePin(_ bubble:Bubble) {
//        if bubble.isPinned, Secretary.shared.pinnedBubblesCount == 1 {
//            secretary.showFavoritesOnly = false
//        }
        bubble.isPinned.toggle()
        PersistenceController.shared.save()
    }
    
    ///delta is always zero if user taps start. if user uses start delay, delta is not zero
    func toggleBubbleStart(_ bubble:Bubble, delta:TimeInterval? = nil) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  { return }
       removeDelay(for: bubble)
        
        let startDelayCompensation = delta ?? 0
        
        switch bubble.state {
            case .brandNew: /* changes to .running */
                //create first session and add first pair to the session
                let newSession = Session(context: bubble.managedObjectContext!)
                let newPair = Pair(context: bubble.managedObjectContext!)
                
                newPair.start = Date().addingTimeInterval(startDelayCompensation)
                newSession.created = Date().addingTimeInterval(startDelayCompensation)
                
                bubble.addToSessions(newSession)
                newSession.addToPairs(newPair)
                
                if !path.isEmpty { bubble.syncSmallBubbleCell = true }
                
                //1 both
                secretary.addNoteButton_bRank = nil //clear first
                secretary.addNoteButton_bRank = Int(bubble.rank)
                
                bubble.coordinator.update(.start)
                                                
            case .paused:  /* changes to running */
                //create new pair, add it to currentSession
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date().addingTimeInterval(startDelayCompensation)
                bubble.lastSession?.addToPairs(newPair)
                
                if !path.isEmpty { bubble.syncSmallBubbleCell = true }
                
                //1 both
                secretary.addNoteButton_bRank = nil //clear first
                secretary.addNoteButton_bRank = Int(bubble.rank)
                
                bubble.coordinator.update(.start)
                
            case .running: /* changes to .paused */
                let currentPair = bubble.lastPair
                currentPair?.pause = Date()
                
                if bubble.syncSmallBubbleCell { bubble.syncSmallBubbleCell = false }
                
                //⚠️ closure runs on the main queue. whatever you want the user to see put in that closure otherwise it will fail to update!!!!
                currentPair?.computeDuration(.atPause) {
                    
                    //set bubble properties
                    bubble.currentClock += currentPair!.duration
                    bubble.coordinator.componentsPublisher.send(bubble.currentClock.timeComponentsAsStrings)
                    
                    bubble.lastSession?.computeDuration {
                        //no need to run any code in the completion
                        PersistenceController.shared.save()
                    }
                }
                
                //remove only that
                if secretary.addNoteButton_bRank == Int(bubble.rank) { secretary.addNoteButton_bRank = nil
                } //1
                
                bubble.coordinator.update(.pause)
                
            case .finished: return
        }
        PersistenceController.shared.save()
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        
        bubble.hasCalendar.toggle()
        PersistenceController.shared.save()
        
        //create events for this bubbble
        if bubble.hasCalendar { CalendarManager.shared.bubbleToEventify = bubble }
        
//        confirm_CalOn = (true, bubble.hasCalendar)
//        delayExecution(.now() + 0.5) { [weak self] in
//            self?.confirm_CalOn = (false, bubble.hasCalendar)
//        }
    }
    
    func showMoreOptions(for bubble:Bubble) {
        //set Published property triggers UI update
        //MoreOptionsView displayed
        secretary.theOneAndOnlyEditedSDB = bubble.sdb
    }
    
    //SDBubble
    func toggleSDBStart(_ sdb:StartDelayBubble) {
        UserFeedback.singleHaptic(.heavy)
        sdb.toggleStart()
    }
    
    // MARK: -
    //⚠️ super hard to get it right
    func reorderRanks(_ sourceRank:Int64, _ destRank:Int64, _ moveBottom:Bool = false) {
        if sourceRank == destRank { return }
        
        let bubbleMovedDown = sourceRank > destRank
        
        //get bubbles sorted by rank
        let request = Bubble.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: false)]
        let bubbles = try! PersistenceController.shared.viewContext.fetch(request)
        
        //change ranks temporarily so that you can simply "move" a bubble without removing it. just by assigning a new rank
        bubbles.forEach { $0.rank = 2 * $0.rank + 1 }
        
        let sourceBubble = bubble(for: Int(sourceRank) * 2 + 1)
        let destBubble = bubble(for: Int(destRank) * 2 + 1)
        
        if bubbleMovedDown {
            if moveBottom { sourceBubble?.rank = 0 }
            else { sourceBubble?.rank = destBubble!.rank + 1 }
        } else {
            sourceBubble?.rank = destBubble!.rank + 1
        }
        
       let sortedBubbles = bubbles.sorted { $0.rank > $1.rank }
        
        for (index, bubble) in sortedBubbles.enumerated() {
            bubble.rank = Int64(sortedBubbles.count - 1 - index)
        }
        
        UserDefaults.resetRankGenerator(sortedBubbles.count) //reset rank generator
        
        PersistenceController.shared.save()
    }
    
    // FIXME: ⚠️ not complete!
    func endSession(_ bubble:Bubble) {
        //make sure no startDelayBubble displayed at this point
        removeDelay(for: bubble)
        
        secretary.addNoteButton_bRank = nil //1
        
        if bubble.state == .brandNew { return }
        
        bubble.syncSmallBubbleCell = false
        
        //reset bubble clock
        bubble.currentClock = bubble.initialClock
        
        updateTimeComponents([bubble])
        bubble.coordinator.update(.pause)
                
        //mark session as ended
        bubble.lastSession?.isEnded = true
                
        let bubbleWasStillRunningWhenSessionWasEnded = bubble.lastPair!.pause == nil
        
        if bubbleWasStillRunningWhenSessionWasEnded {
            bubble.lastPair!.pause = Date() //close last pair
            
            //compute lastPair duration first [on background thread 🔴]
            bubble.lastPair?.computeDuration(.atEndSession) {
                bubble.lastSession?.computeDuration {
                    self.createCalendarEventIfRequiredAndSaveToCoreData(for: bubble)
//                    PersistenceController.shared.save()
                }
            }
        }
        else { createCalendarEventIfRequiredAndSaveToCoreData(for: bubble) }
    }
    
    ///createds calendar events only if that bubble has calendar, otherwise it only saves to coredata
    private func createCalendarEventIfRequiredAndSaveToCoreData(for bubble:Bubble) {
        if !bubble.sessions_.isEmpty && bubble.hasCalendar {
            CalendarManager.shared.createNewEvent(for: bubble.lastSession)
            
            //display Cal Event Added to Calendar App confirmation to the user
            secretary.confirm_CalEventCreated = bubble.rank
            delayExecution(.now() + 3) { self.secretary.confirm_CalEventCreated = nil }
        }
        
        PersistenceController.shared.save()
    }
    
    func userTogglesDetail(_ rank:Int?) {
        //identify bubble using rank
        //ask bubble to start/stop updating smallBubbleCellTimeComponents
        guard
            let bubble = bubble(for: rank) else { return }
        bubble.syncSmallBubbleCell = rank != nil
    }
    
    // MARK: - Helpers
    func bubble(for rank:Int?) -> Bubble? {
        guard let rank = rank else { return nil }
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank = %i", rank)
        let context = PersistenceController.shared.viewContext
        let bubble = try! context.fetch(request).first
        return bubble
    }
    
    func index(of rank:Int64) -> Int? {
        let request = Bubble.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: false)]
        let bubbles = try! PersistenceController.shared.viewContext.fetch(request)
        
        for (index, bubble) in bubbles.enumerated() {
            if bubble.rank == rank { return index }
        }
        
        return nil
    }
    
    ///save to CoreData either bubble.note or pair.note
    func save(_ textInput:String, forObject object:NSManagedObject) {
        var note = textInput
        note.removeWhiteSpaceAtBothEnds()
        
        switch object.entity.name {
            case "Bubble":
                let bubble = object as! Bubble
                bubble.note = note
                bubble.isNoteHidden = false

                //add new item to bubbleHistory
                let context = bubble.managedObjectContext
                let newHistoryItem = BubbleSavedNote(context: context!)
                newHistoryItem.date = Date()
                newHistoryItem.note = note
                bubble.addToHistory(newHistoryItem)
                
                CalendarManager.shared.updateExistingEvent(.title(bubble))
                
            case "Pair" :
                let pair = object as! Pair
                pair.note = note
                pair.isNoteHidden = false

                //add new item to bubbleHistory
                let context = pair.managedObjectContext
                let newHistoryItem = PairSavedNote(context: context!)
                newHistoryItem.date = Date()
                newHistoryItem.note = note
                pair.addToHistory(newHistoryItem)
                
                CalendarManager.shared.updateExistingEvent(.notes(pair.session!))
                
            default: return
        }
    }
    
    //delete BubbleSticky in List
    func delete(_ savedNote:BubbleSavedNote) {
        let context = PersistenceController.shared.viewContext
        context.delete(savedNote)
        PersistenceController.shared.save()
    }
    
    //delete PairSticky in List
    func delete(_ savedNote:PairSavedNote) {
        let context = PersistenceController.shared.viewContext
        context.delete(savedNote)
        PersistenceController.shared.save()
    }
    
    //delete BubbleSticky
    func deleteStickyNote(for bubble:Bubble) {
        bubble.note = nil
        CalendarManager.shared.updateExistingEvent(.title(bubble))
        PersistenceController.shared.save()
    }
    
    //delete PairSticky
    func deleteStickyNote(for pair:Pair) {
        pair.note = nil
        PersistenceController.shared.save()
        
        //update Calendar Event
        CalendarManager.shared.updateExistingEvent(.notes(pair.session!))
    }
    
    // MARK: - MoreOptionsView
    //color change
    func saveColor(for bubble:Bubble, to newColor:String) {
        //don't do anything unless user changed color
        if bubble.color == newColor { return }
        
        //model: change color and save coredata
        bubble.color = newColor
        PersistenceController.shared.save()
        
        //user feedback: tactile feedback
        UserFeedback.singleHaptic(.medium)
                                
        //user feedback: flash "color changed" confirmation
//        confirm_ColorChange = true //show confirmation
        delayExecution(.confirmation) {//after 0.7 seconds
//            self.confirm_ColorChange = false //hide confirmation
            self.secretary.theOneAndOnlyEditedSDB = nil //dismiss
        }
    }
    
    // start delay
    func saveDelay(for bubble:Bubble, _ userEnteredDelay:Int) {
        secretary.theOneAndOnlyEditedSDB?.referenceDelay = Int64(userEnteredDelay)
        secretary.theOneAndOnlyEditedSDB?.currentDelay = Float(userEnteredDelay)
        PersistenceController.shared.save()
        secretary.theOneAndOnlyEditedSDB = nil
    }
    
    ///referenceDelay = 0, currentDelay = 0
    func removeDelay(for bubble:Bubble?) {
        guard let bubble = bubble else { return }
        if bubble.sdb!.referenceDelay == 0 { return }
        
        bubble.sdb?.removeDelay()
    }
    
    ///currentDelay = referenceDelay
    func resetDelay(for sdb:StartDelayBubble) { sdb.resetDelay() }
    
    ///reference startDelay
    func computeReferenceDelay(_ sdb:StartDelayBubble, _ value: Int) {
        UserFeedback.singleHaptic(.medium)
        sdb.referenceDelay += Int64(value)
        sdb.currentDelay = Float(sdb.referenceDelay)
    }
    
    private func observe_delayReachedZero_Notification() {
        NotificationCenter.default.addObserver(forName: .sdbEnded, object: nil, queue: nil) { [weak self] notification in
            
            let sdb = notification.object as? StartDelayBubble
            guard
                let bubble = sdb?.bubble,
                let info = notification.userInfo as? [String:TimeInterval],
                let delta = info["delta"]
            else { fatalError() }
                        
            DispatchQueue.main.async {
                //start bubble automatically
                //remove SDBCell from BubbleCell
                self?.toggleBubbleStart(bubble, delta: delta)
                
                self?.secretary.theOneAndOnlyEditedSDB = nil //dismiss MoreOptionsView
                
                PersistenceController.shared.save()
            }
        }
    }
    
    // MARK: - Little Helpers
    var fiveSecondsBubble:Bubble? { bubble(for: secretary.addNoteButton_bRank) }
}

// MARK: - Handle SDBubble start and pause and shit
extension ViewModel {
    func allBubbles(runningOnly:Bool = false) -> [Bubble] {
        let context = PersistenceController.shared.viewContext
        let request = Bubble.fetchRequest()
                    
        if let bubbles = try? context.fetch(request) {
            return runningOnly ? bubbles.filter { $0.state == .running } : bubbles
        } else {
            return []
        }
    }
    
    ///all start delay bubbles
    func allSDBs(visibleOnly:Bool = false) -> [StartDelayBubble] {
        let context = PersistenceController.shared.viewContext
        let request = StartDelayBubble.fetchRequest()
        if visibleOnly {
            let predicate = NSPredicate(format: "referenceDelay > 0")
            request.predicate = predicate
        }
                    
        if let sdbArray = try? context.fetch(request) { return sdbArray }
        else { return [] }
    }
}

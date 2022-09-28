//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//  CoreData constraints https://www.youtube.com/watch?v=NZIlmRSB8l8

import Foundation
import SwiftUI
import Combine
import CoreData


class ViewModel: ObservableObject {
    ///MoreOptionsView
    @Published var theOneAndOnlyEditedSDB:SDB? //StartDelayBubble
    
    @Published var confirm_NoDelay = false
    @Published var showConfirmation_DelayWasChanged = false
    
    ///calendarEvent created for bubble.rank. if rank != nil, confirmation will be displayed in the appropriate bubbleCell
    @Published var confirm_CalEventCreated: Int64? = nil
    
    // MARK: - Confirmation Flashes
    @Published var confirm_AlwaysOnDisplay = false
    @Published var confirm_CalendarOn = (show:false, isCalOn:false)
    
    // MARK: - Alerts
    @Published var showAlert_AlwaysOnDisplay = false
    
    // MARK: -
    @Published var showDeleteAction_bRank:Int? = nil
    @Published var deleteViewOffset:CGFloat? = nil
    
    @Published var isDetailViewShowing = false
    
    @Published var pairOfNotesList:Pair?
    
    @Published var notesList_bRank:Int? = nil //bubble rank
    @Published var isPaletteShowing = false
    
    @Published var rankOfSelectedBubble:Int?
    @Published var idOfSelectedBubble:Bubble.ID?
    
    @Published var showMoreOptionsInfo = false
    
    ///allow user to drag and drop tableView cells
    ///.onMove view modifier will not be nil
    @Published var allowOnMove = false
        
    // MARK: -
    init() {
        let request = Bubble.fetchRequest()
        let bubbles = try? PersistenceController.shared.viewContext.fetch(request)
        updateCurrentClock(of: bubbles)
        observe_delayReachedZero_Notification()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    // MARK: -
    private func updateCurrentClock(of bubbles:[Bubble]?) {
        delayExecution(.now() + 0.0001) {
            bubbles?.forEach {
                if $0.state != .running {
                    $0.components = $0.currentClock.timeComponentsAsStrings
                }
            }
        }
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
    func createBubble(_ kind:Bubble.Kind, _ color:String) {
        let backgroundContext = PersistenceController.shared.backgroundContext
                
        //bubble
        let newBubble = Bubble(context: backgroundContext)
        newBubble.created = Date()
        
        newBubble.kind = kind
        switch kind {
            case .timer(let initialClock):
                newBubble.initialClock = initialClock
            default: newBubble.initialClock = 0
        }
        
        newBubble.color = color
        newBubble.rank = Int64(UserDefaults.generateRank())
        
        let sdb = SDB(context: backgroundContext)
        newBubble.sdb = sdb
        
        try? backgroundContext.save()
    }
    
    func delete(_ bubble:Bubble) {
        let viewContext = PersistenceController.shared.viewContext
        viewContext.delete(bubble)
        try? viewContext.save()
    }
    
    ///delete all sessions and pairs and make it brandNew
    func reset(_ bubble:Bubble) {
        guard !bubble.sessions_.isEmpty else { return }
        
        let viewContext = PersistenceController.shared.viewContext
        bubble.created = Date()
        bubble.currentClock = bubble.initialClock
        bubble.components = bubble.initialClock.timeComponentsAsStrings
        bubble.sessions?.forEach { viewContext.delete($0 as! Session) }
        try? viewContext.save()
    }
    
    func togglePin(_ bubble:Bubble) {
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
                let newSession = Session(context: PersistenceController.shared.viewContext)
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date().addingTimeInterval(startDelayCompensation)
                bubble.addToSessions(newSession)
                newSession.created = Date().addingTimeInterval(startDelayCompensation)
                newSession.addToPairs(newPair)
                
                bubble.syncSmallBubbleCell = true
                                
            case .paused:  /* changes to running */
                //create new pair, add it to currentSession
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date().addingTimeInterval(startDelayCompensation)
                bubble.lastSession?.addToPairs(newPair)
                
                bubble.syncSmallBubbleCell = true
                
            case .running: /* changes to .paused */
                let currentPair = bubble.lastPair
                currentPair?.pause = Date()
                bubble.syncSmallBubbleCell = false
                
                //⚠️ closure runs on the main queue. whatever you want the user to see put in that closure otherwise it will fail to update!!!!
                currentPair?.computeDuration(.atPause) {
                    
                    //set bubble properties
                    bubble.currentClock += currentPair!.duration
                    bubble.components = bubble.currentClock.timeComponentsAsStrings
                    
                    bubble.lastSession?.computeDuration {
                        //no need to run any code in the completion
                        PersistenceController.shared.save()
                    }
                }
                
            case .finished: return
        }
                
        if bubble.state == .running { bubble.addObserver() }
        
        PersistenceController.shared.save()
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        
        bubble.hasCalendar.toggle()
        PersistenceController.shared.save()
        
        //create events for this bubbble
        if bubble.hasCalendar { TimersApp.calManager.bubbleToEventify = bubble }
        
        confirm_CalendarOn = (true, bubble.hasCalendar)
        delayExecution(.now() + 0.5) { [weak self] in
            self?.confirm_CalendarOn = (false, bubble.hasCalendar)
        }
    }
    
    func showMoreOptions(for bubble:Bubble) {
        //set @Published property triggers UI update
        //MoreOptionsView displayed
        theOneAndOnlyEditedSDB = bubble.sdb
    }
    
    //SDBubble
    func toggleSDBStart(_ sdb:SDB) {
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
        
        if bubble.state == .brandNew { return }
        
        bubble.syncSmallBubbleCell = false
        
        //reset bubble clock
        bubble.currentClock = bubble.initialClock
        bubble.components = bubble.initialClock.timeComponentsAsStrings
        
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
            TimersApp.calManager.createNewEvent(for: bubble.lastSession)
            
            //display Cal Event Added to Calenda App confirmation to the user
            confirm_CalEventCreated = bubble.rank
            delayExecution(.now() + 0.7) { self.confirm_CalEventCreated = nil }
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
        guard let rank = rank else { fatalError() }
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
                
                TimersApp.calManager.updateExistingEvent(.title(bubble))
                
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
                
                TimersApp.calManager.updateExistingEvent(.notes(pair.session!))
                
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
    func deleteNote(for bubble:Bubble) {
        bubble.note = nil
        TimersApp.calManager.updateExistingEvent(.title(bubble))
        
        PersistenceController.shared.save()
    }
    
    //delete PairSticky
    func deleteNote(for pair:Pair) {
        pair.note = nil
        //update Calendar Event
        
        PersistenceController.shared.save()
        TimersApp.calManager.updateExistingEvent(.notes(pair.session!))
    }
    
    // MARK: -
    func compute_deleteView_YOffset(for frame:CGRect) -> CGFloat {
        guard !isDetailViewShowing else { return 0 }
        
        let cellDeleteViewGap = CGFloat(70)
        
        let cellLow = frame.origin.y + frame.height
        
        let deleteViewHeight = DeleteView.height
        let deleteViewHigh = (UIScreen.size.height - deleteViewHeight)/2
        let deleteViewLow = deleteViewHigh + deleteViewHeight
        
        //available space below bubble cell
        let spaceBelowCell = UIScreen.size.height - cellLow
        
        //put deleteActionView below cell it's the prefered way to go
        let putBelow = spaceBelowCell - (cellDeleteViewGap + deleteViewHeight) > 0
        let delta = cellLow - deleteViewHigh
        
        let deleteView_YOffset:CGFloat
        
        if putBelow { deleteView_YOffset = delta + cellDeleteViewGap }
        else {//put up
            deleteView_YOffset = frame.origin.y - (deleteViewLow + cellDeleteViewGap) - 10
        }
        
        return deleteView_YOffset
    }
    
    // MARK: -
    func makeBubblesOnFirstAppLaunchEver() {
        if UserDefaults.shared.bool(forKey: UserDefaults.Key.firstAppLaunchEver) {
            print("makeBubblesOnFirstAppLaunchEver")
        } else {
            print("do not makeBubblesOnFirstAppLaunchEver")
        }
    }
    
    // MARK: -
    func changeColor(for bubble:Bubble, to newColor:String) {
        guard let sdb = theOneAndOnlyEditedSDB else { fatalError() }
        
        //change color and save CoreData
        if bubble.color == newColor { return }
        bubble.color = newColor
        
        if sdb.referenceDelay != 0 {//there is a delay set
            UserFeedback.singleHaptic(.medium)
            PersistenceController.shared.save()
            showConfirmation_DelayWasChanged = true
            
            delayExecution(.now() + 0.6) {
                self.showConfirmation_DelayWasChanged = false
                self.theOneAndOnlyEditedSDB = nil
            }
            
        } else {//no delay set
            UserFeedback.singleHaptic(.medium) //haptic feedback
            self.theOneAndOnlyEditedSDB = nil
        }
        
        //save CoreData
        PersistenceController.shared.save()
    }
    
    // MARK: - StartDelay SDB
    ///save delay and dismiss MoreOptionsView
    func saveDelay(for bubble:Bubble, _ storedDelay:Int) {
        /*
       if user hasn't changed start delay, dismiss and return
         */
        guard
            let referenceDelay = bubble.sdb?.referenceDelay,
            referenceDelay != storedDelay
        else {
            self.theOneAndOnlyEditedSDB = nil //dismiss MOV
            return
        }
                 
        showConfirmation_DelayWasChanged = true //set back to false after dispatchTime
        
        delayExecution(.now() + 0.8) {
            self.showConfirmation_DelayWasChanged = false
            self.theOneAndOnlyEditedSDB = nil //dismiss MOV
        }
        
        if let sdb = theOneAndOnlyEditedSDB { sdb.currentDelay = Float(sdb.referenceDelay) }
        
        PersistenceController.shared.save()
    }
    
    ///user long presses in MoreOptionsView
    func removeDelay(for bubble:Bubble?) {
        guard let bubble = bubble else { return }
        if bubble.sdb!.referenceDelay == 0 { return }
        
        bubble.sdb?.removeDelay()
    }
    
    //long press SDBButton
    func resetDelay(for sdb:SDB) { sdb.resetDelay() }
    
    ///reference startDelay
    func computeReferenceDelay(_ sdb:SDB, _ value: Int) {
        UserFeedback.singleHaptic(.medium)
        sdb.referenceDelay += Int64(value)
        sdb.currentDelay = Float(sdb.referenceDelay)
    }
    
    private func observe_delayReachedZero_Notification() {
        NotificationCenter.default.addObserver(forName: .sdbEnded, object: nil, queue: nil) { [weak self] notification in
            
            let sdb = notification.object as? SDB
            guard
                let bubble = sdb?.bubble,
                let info = notification.userInfo as? [String:TimeInterval],
                let delta = info["delta"]
            else { fatalError() }
                        
            DispatchQueue.main.async {
                //start bubble automatically
                //remove SDBCell from BubbleCell
                self?.toggleBubbleStart(bubble, delta: delta)
                
                self?.theOneAndOnlyEditedSDB = nil //dismiss MoreOptionsView
                
                PersistenceController.shared.save()
            }
        }
    }
    
    // MARK: -
    func removeDelay(for bubble:Bubble) {
        bubble.sdb?.removeDelay()
    }
    
    // MARK: - User Intents
    func addObserver(for bubble: Bubble) {
        bubble.addObserver()
    }
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
    func allSDBs(visibleOnly:Bool = false) -> [SDB] {
        let context = PersistenceController.shared.viewContext
        let request = SDB.fetchRequest()
        if visibleOnly {
            let predicate = NSPredicate(format: "referenceDelay > 0")
            request.predicate = predicate
        }
                    
        if let sdbArray = try? context.fetch(request) { return sdbArray }
        else { return [] }
    }
}

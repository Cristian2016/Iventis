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
    @Published var showDeleteAction_bRank:Int? = nil
    @Published var deleteViewOffset:CGFloat? = nil
    
    @Published var isDetailViewShowing = false
    
    @Published var pairOfNotesList:Pair?
    
    @Published var notesList_bRank:Int? = nil //bubble rank
    @Published var isPaletteShowing = false
    
    @Published var rankOfSelectedBubble:Int?
    @Published var idOfSelectedBubble:Bubble.ID?
    
    //MoreOptionsView 3 @Published
    
    // MARK: -
    init() {
        let request = Bubble.fetchRequest()
        let bubbles = try? PersistenceController.shared.viewContext.fetch(request)
        updateCurrentClock(of: bubbles)
    }
    
    // MARK: -
    private func updateCurrentClock(of bubbles:[Bubble]?) {
        delayExecution(.now() + 0.0001) {
            bubbles?.forEach {
                if $0.state != .running {
                    $0.bCell_Components = $0.currentClock.timeComponentsAsStrings
                }
            }
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
            
    private let timer = BackgroundTimer(DispatchQueue(label: "BackgroundTimer", attributes: .concurrent))
    
    func backgroundTimer(_ action:BackgroundTimer.Action) {
        switch action {
            case .start: timer.perform(.start)
            case .pause: timer.perform(.pause)
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
        sdb.observeSDBTimer()
        
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
        bubble.bCell_Components = bubble.initialClock.timeComponentsAsStrings
        bubble.sessions?.forEach { viewContext.delete($0 as! Session) }
        try? viewContext.save()
    }
    
    func togglePin(_ bubble:Bubble) {
        bubble.isPinned.toggle()
        PersistenceController.shared.save()
    }
    
    func toggleStart(_ bubble:Bubble) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  { return }
        
        switch bubble.state {
            case .brandNew: /* changes to .running */
                //create first session and add first pair to the session
                let newSession = Session(context: PersistenceController.shared.viewContext)
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date()
                bubble.addToSessions(newSession)
                newSession.created = Date()
                newSession.addToPairs(newPair)
                                
            case .paused:  /* changes to running */
                //create new pair, add it to currentSession
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date()
                bubble.lastSession?.addToPairs(newPair)
                
            case .running: /* changes to .paused */
                let currentPair = bubble.lastPair
                currentPair?.pause = Date()
                bubble.continueToUpdateSmallBubbleCell = false
                
                //⚠️ closure runs on the main queue. whatever you want the user to see put in that closure otherwise it will fail to update!!!!
                currentPair?.computeDuration(.atPause) {
                    
                    //set bubble properties
                    bubble.currentClock += currentPair!.duration
                    bubble.bCell_Components = bubble.currentClock.timeComponentsAsStrings
                    
                    bubble.lastSession?.computeDuration {
                        //no need to run any code in the completion
                        PersistenceController.shared.save()
                    }
                }
                
            case .finished: return
        }
        
        PersistenceController.shared.save()
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        
        bubble.hasCalendar.toggle()
        PersistenceController.shared.save()
        
        //create events for this bubbble
        if bubble.hasCalendar { TimersApp.calManager.bubbleToEventify = bubble }
    }
    
    func showMoreOptions(for bubble:Bubble) {
        sdbDelay = bubble.sdb!.delay
        sdb = bubble.sdb
    }
    
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
        if bubble.state == .brandNew { return }
        
        bubble.continueToUpdateSmallBubbleCell = false
        
        //reset bubble clock
        bubble.currentClock = bubble.initialClock
        bubble.bCell_Components = bubble.initialClock.timeComponentsAsStrings
        
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
        }
        
        PersistenceController.shared.save()
    }
    
    func userTogglesDetail(_ rank:Int?) {
        //identify bubble using rank
        //ask bubble to start/stop updating smallBubbleCellTimeComponents
        guard
            let bubble = bubble(for: rank) else { return }
        bubble.continueToUpdateSmallBubbleCell = rank != nil
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
    
    // MARK: - MoreOptionsView
    @Published var sdb:SDB?
    @Published var startDelayWasReset = false
    @Published var startDelayWasSet = false
    var sdbDelay:Int64 = 0
    
    func changeColor(for bubble:Bubble, to newColor:String) {
        guard let dsb = sdb else { fatalError() }
        
        //change color and save CoreData
        if bubble.color == newColor { return }
        bubble.color = newColor
        
//        if moreOptionsData.startDelay != bubble.startDelay {//there is a delay set
//            UserFeedback.singleHaptic(.medium)
//            PersistenceController.shared.save()
//            startDelayWasSet = true
//
//            let delay = (bubble.startDelay != 0) ? DispatchTime.now() + 1 : .now()
//
//            delayExecution(delay) {
//                self.startDelayWasSet = false
//                self.moreOptionsData = nil //dismiss
//            }
//
//        } else {//no delay set
//            UserFeedback.singleHaptic(.medium) //haptic feedback
//            self.moreOptionsData = nil //dismiss
//        }
        
        //save CoreData
        PersistenceController.shared.save()
    }
    
    func saveAndDismissMoreOptionsView(_ bubble:Bubble) {
        let userChangedStartDelay = sdbDelay != bubble.sdb!.delay
        
        if userChangedStartDelay {
            UserFeedback.singleHaptic(.medium)
            PersistenceController.shared.save()
            startDelayWasSet = true

            let delay = (bubble.sdb!.delay != 0) ? DispatchTime.now() + 1 : .now()

            delayExecution(delay) {
                self.sdbDelay = 0
                self.sdb = nil
                self.startDelayWasSet = false
            }

        } else {
            //dismiss MoreOptionsView
            self.sdb = nil
            self.sdbDelay = 0
        }
    }
    
    func computeStartDelay(_ sdb:SDB, _ value: Int) {
        UserFeedback.singleHaptic(.medium)
        sdb.delay += Int64(value)
    }
    
    func resetStartDelay(for bubble:Bubble) {
        guard let sdb = bubble.sdb else { fatalError() }
        
        if sdb.delay != 0 {
            sdb.delay = 0
            PersistenceController.shared.save()
        }
        
        UserFeedback.doubleHaptic(.medium)
    }
}

// MARK: - Control StartDelayView and Model
extension ViewModel {
    
    // MARK: - SDBCell User Intents
    ///start/pause SDB.timer
    func toggle(_ sdb:SDB) {
        UserFeedback.singleHaptic(.heavy)
        sdb.toggleStart()
    }
}

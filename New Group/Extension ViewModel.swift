//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//  CoreData constraints https://www.youtube.com/watch?v=NZIlmRSB8l8
//1 Add Tag and Undo Start. User can undo start or tag activity within 5 seconds after starting the bubble
//1 make sure to set fiveSeconds_bRank to nil first, then set it to a new value
//2 fetches bubbles using a backgroundContext but I don't know how to use it afterwards
//3 notifies PairBubbleCellCoordinator that detailview is visible or not
//4 the reason for the 0.005 slight delay is to allow PairBubbleCellCoordinator initialize first otherwise it will not receive any notifications, duh :))
//5 PairBubbleCellCoordinator is interested in knowing when DetailView is visible or hidden, since it needs to resume or pause work
//6 creates new bubble.session and new pair on a bContext. changes will be seen by viewContxt only if you save bContext first!
//7 from here on viewContext can see all changes
//8 when creating a bubble, it is necessary to bContext.save(). after that vContext 'absorbs' the object and bContext will have no obj registered, but vContext.registeredObjs increases by one. No need to vContext.save()!!!
//9 after deleting the obj, must do both vContext and bContext save. vContext must always be used on mainQueue, otherwise error!!!
//10 if you forget about the predicate, it will delete all sessions of all bubbles :))
//11 save changes to bContext and, if deleted Session was lastSession, update BubbleCell UI as well
//12 ⚠️ never access viewContext on a background thread! always use UI thread (main thread)
//13 both contexts must save [bContext and viewContext]
//14 after save bContext -> viewContext can see the changes -> so UI update can be done here
//15 Update UI only after bContext has saved
//16 why?????? if I don't reset bContext sessions will still be there after batchdelete
//17 if ordinary bubbles are hidden & bubble to delete is pinned and pinned section has only one item, show ordinary!
//18 Viewmodel listens for killStartDelayBubble notifications. ex: user sets a startDelay of 30 seconds. after 30 seconds StartDelayButton (SDButton) will be removed and bubble will be started. but it will be started with a correction (startCorrection) that is computed by sdbCoordinator. ViewModel.toggleBubbleStart calls the startCorrection "delta". Maybe I should change names a bit :)
//19 set startDelay or replace existing startDelay with a new delay. if no sdb, create sdb and set startDelay. if sdb exists already, remove it and create a new sdb with a new startDelay
//20 DurationPickerView.Manager posts when user created a valid duration for the timer. this means timer can be created by the viewModel
//21 initially [on the moment of bubble creation] currentClock has same value as initialClock
//22 ⚠️ no need to save viewContext, completion handler does not run onMain Thread in this particular case

import Foundation
import SwiftUI
import Combine
import CoreData
import MyPackage
import WidgetKit

extension ViewModel {
    func start(_ bubble:Bubble, _ delayCorrection:TimeInterval) {
        if bubble.state == .finished  { return }
        
        let shouldKillTimer =
        bubble.currentClock <= Float(delayCorrection)
        
        UserFeedback.singleHaptic(.rigid)
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform { [weak self] in
            guard let self = self else { return }
            
            let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            let rank = bBubble.rank
            self.secretary.setAddNoteButton_bRank(to: Int(rank))
            
            if !shouldKillTimer {
                self.setNotification(of: bBubble, for: .start)
                self.secretary.setMostRecentlyUsedBubble(to: rank)
            }
            
            let newPair = Pair(context: bContext)
            newPair.start = Date().addingTimeInterval(-delayCorrection)
            
            if bBubble.state == .brandNew {
                let newSession = Session(context: bContext)
                newSession.created = Date().addingTimeInterval(-delayCorrection)
                newSession.addToPairs(newPair)
                bBubble.addToSessions(newSession)
                
            } else if bBubble.state == .paused {
                bBubble.lastSession?.handleBubbleID(.assign(newPair))
                bBubble.lastSession?.addToPairs(newPair)
            }
            
            PersistenceController.shared.save(bContext) {
                self.calManager.shouldEventify(bBubble)
                self.calManager.updateEvent(.title(bBubble))
                
                DispatchQueue.main.async {
                    bubble.coordinator.update(for: .start)
                    bubble.pairBubbleCellCoordinator.update(.user(.start))
                }
            }
        }
    }
    func toggle(_ bubble:Bubble) {
        if bubble.state == .finished  { return }
        
        UserFeedback.singleHaptic(.rigid)
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform { [weak self] in
            guard let self = self else { return }
            
            let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            switch bBubble.state {
                case .brandNew, .paused:
                    self.setNotification(of: bBubble, for: .start)
                    
                    let rank = bBubble.rank
                    self.secretary.setAddNoteButton_bRank(to: Int(rank))
                    self.secretary.setMostRecentlyUsedBubble(to: rank)
                    
                    let newPair = Pair(context: bContext)
                    newPair.start = Date()
                    
                    if bBubble.state == .brandNew {
                        let newSession = Session(context: bContext)
                        newSession.created = Date()
                        newSession.addToPairs(newPair)
                        bBubble.addToSessions(newSession)
                        
                    } else if bBubble.state == .paused {
                        bBubble.lastSession?.handleBubbleID(.assign(newPair))
                        bBubble.lastSession?.addToPairs(newPair)
                    }
                    
                    //this also makes changes visible to the viewContext as well
                    PersistenceController.shared.save(bContext) {
                        print("0/5 pair created \(newPair.start)")
                        self.calManager.shouldEventify(bBubble)
                        self.calManager.updateEvent(.title(bBubble))
                        
                        DispatchQueue.main.async {
                            bubble.coordinator.update(for: .start)
                            bubble.pairBubbleCellCoordinator.update(.user(.start))
                        }
                    }
                    
                case .running: /* changes to .paused */
                    self.setNotification(of: bBubble, for: .pause)
                    
                    if self.secretary.addNoteButton_bRank == Int(bBubble.rank) { self.secretary.setAddNoteButton_bRank(to: nil)
                    }
                    
                    guard let currentPair = bBubble.lastPair else { return }
                    
                    currentPair.pause = Date()
                    currentPair.computeDuration(.atPause)
                    
                    if bBubble.isTimer {
                        bBubble.currentClock -= currentPair.duration
                    } else {
                        bBubble.currentClock += currentPair.duration
                    }
                    
                    bBubble.lastSession!.computeDuration()
                    
                    PersistenceController.shared.save(bContext) {
                        DispatchQueue.main.async {
                            bubble.coordinator.update(for: .pause)
                            bubble.pairBubbleCellCoordinator.update(.user(.pause))
                        }
                    }
                    
                default: break
            }
        }
    }
    
    func bubbleTimer(_ action:BubbleTimer.Action) {
        switch action {
            case .start:
                if !bubbleTimerIsRunning {
                    bubbleTimer.perform(.start)
                    bubbleTimerIsRunning = true
                }
            case .pause:
                if bubbleTimerIsRunning {
                    bubbleTimer.perform(.pause)
                    bubbleTimerIsRunning = false
                }
        }
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
        
        UserDefaults.resetRankGenerator(to: sortedBubbles.count) //reset rank generator
        
        // FIXME: -
        PersistenceController.shared.save()
    }
    
    ///createds calendar events only if that bubble has calendar, otherwise it only saves to coredata
    private func createCalEventAndSave(for bubble:Bubble) {
        guard bubble.isCalendarEnabled else { return }
        
        calManager.eventify(bubble.lastSession)
        
        DispatchQueue.main.async {
            self.secretary.showConfirmEventCreated(bubble.rank)
        }
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
    
    // MARK: Observers
    func observe_KillDelayBubble() {
        center.addObserver(forName: .killDelayBubble, object: nil, queue: nil) {[weak self] in
            guard
                let rank = $0.userInfo?["rank"] as? Int64,
                let delayCorrection = $0.userInfo?["startCorrection"] as? TimeInterval,
                let timer = self?.bubble(for: Int(rank))
            else { return }
            
            //start bubble and remove start delay
            self?.removeDelay(for: timer)
            
            self?.start(timer, delayCorrection)
        }
    } //18
    
    func observe_CreateTimer() {
        center.addObserver(forName: .createTimer, object: nil, queue: nil) { [weak self] in
            guard
                let color = $0.userInfo!["color"] as? String,
                let initialClock = $0.userInfo!["initialClock"] as? Int else { return }
            
            self?.secretary.palette(.hide)
            
            self?.createBubble(.timer(Float(initialClock)), color)
        }
    } //20
    
    func observe_EditTimerDuration() {
        center.addObserver(forName: .editTimerDuration, object: nil, queue: nil) { [weak self] in
            //⚠️ mainThread! should be background operation, no?
            guard
                let rank = $0.userInfo!["rank"] as? Int64,
                let bubble = self?.bubble(for: Int(rank)),
                let initialClock = $0.userInfo!["initialClock"] as? Int else { return }
            
            UserFeedback.singleHaptic(.heavy)
            self?.change(bubble, to: .timer(Float(initialClock)))
            self?.addToHistory(duration: Float(initialClock))
        }
    } //20
    
    ///Bubble.Coordinator.task() notifies if timer must finish
    func observe_KillTimer() {
        center.addObserver(forName: .killTimer, object: nil, queue: nil) { [weak self] in
            let info = $0.userInfo
            
            let overspill = info!["overspill"] as! Float
            let bubbleRank = info!["rank"] as! Int64
            
            let bubble = self?.bubble(for: Int(bubbleRank))
            self?.killTimer(bubble, overspill)
        }
    }
    
    ///overspill is the elapsed time after timer has reached zero. always overspill <= 0
    private func killTimer(_ bubble:Bubble?, _ overspill:Float) {
        guard let bubble = bubble, bubble.isTimer else { return }
        
        reportBlue(bubble, "viewModel.killTimer")
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            let currentPair = thisBubble.lastPair
            
            //close last pair and compute its duration
            currentPair!.pause = Date().addingTimeInterval(TimeInterval(overspill))
            currentPair!.computeDuration(.atPause)
            
            //update currentClock
            thisBubble.currentClock = 0
            
            //compute last session duration
            thisBubble.lastSession!.computeDuration()
            
            PersistenceController.shared.save(bContext) {
                DispatchQueue.main.async {
                    bubble.coordinator.update(.killTimer)
                    bubble.pairBubbleCellCoordinator.update(.user(.pause))
                }
            }
        }
    }
    
    // MARK: - Little Helpers
    func refreshWidgets() {
        saveWidgetData {
            WidgetCenter.shared.reloadTimelines(ofKind: "Fused")
        }
    }
    
    private func saveEmptyWidget() {
        let bubbleData = BubbleData(value: -200,
                                    isTimer: false,
                                    isRunning: false,
                                    color: nil)
        let data = try? JSONEncoder().encode(bubbleData)
        UserDefaults.shared.setValue(data, forKey: "bubbleData")
    }
    
    private func saveWidgetData(_ completion: @escaping () -> Void) {
        guard
            let rank = secretary.mostRecentlyUsedBubble,
            let bubble = bubble(for: Int(rank)) else {
            //empty widget infos means no widget installed
            WidgetCenter.shared.getCurrentConfigurations { [weak self] result in
                if let widgetInfos = try? result.get(), !widgetInfos.isEmpty {
                    //at least one widget installed, but no bubble has widget
                    
                    self?.saveEmptyWidget()
                    completion()
                }
            }
            return
        }
        
        let bubbleData:BubbleData
        
        if bubble.isRunning {
            guard let lastStart = bubble.lastPair?.start else { return }
            
            let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart))
            
            let value = bubble.isTimer ? bubble.currentClock - elapsedSinceLastStart : bubble.currentClock + elapsedSinceLastStart
            
            bubbleData = BubbleData(value: value,
                                    isTimer: bubble.isTimer,
                                    isRunning: bubble.isRunning,
                                    color: bubble.color)
            
        } else {
            bubbleData = BubbleData(value: bubble.currentClock,
                                    isTimer: bubble.isTimer,
                                    isRunning: bubble.isRunning,
                                    color: bubble.color)
        }
        
        let data = try? JSONEncoder().encode(bubbleData)
        UserDefaults.shared.setValue(data, forKey: "bubbleData")
        completion()
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
}

// MARK: - Bubble operations
extension ViewModel {
    // MARK: - User Intents
    func createBubble(_ kind:Bubble.Kind, _ color:String, _ note:String? = nil) {
        
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            let newBubble = Bubble(context: bContext)
            newBubble.created = Date()
            
            switch kind {
                case .timer(let initialClock):
                    newBubble.initialClock = initialClock
                    newBubble.currentClock = initialClock
                default:
                    newBubble.initialClock = 0
                    newBubble.currentClock = 0
            } //
            
            newBubble.color = color
            newBubble.rank = Int64(UserDefaults.generateRank())
            
            if newBubble.isTimer {
                self.addToHistory(duration: newBubble.initialClock)
            }
            
            if let note = note {
                newBubble.note_ = note
                newBubble.isNoteHidden = false
            }
            PersistenceController.shared.save(bContext)
        }
    } //8
    
    func change(_ bubble:Bubble, to kind:Bubble.Kind) {
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        //pause bubble first and then change bubble
        if bubble.isRunning { toggle(bubble) }
        
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            theBubble.lastSession?.handleBubbleID(.increment)
            
            switch kind {
                case .timer(let initialClock):
                    theBubble.initialClock = initialClock
                    theBubble.currentClock = initialClock //changes the interface
                    
                case .stopwatch:
                    theBubble.initialClock = 0
                    theBubble.currentClock = 0 //changes the interface
            }
            
            PersistenceController.shared.save(bContext) {
                DispatchQueue.main.async {
                    bubble.coordinator.isTimer = kind != .stopwatch
                    bubble.coordinator.refreshBubble(on: .change)
                }
            }
        }
    }
    
    func deleteBubble(_ bubble:Bubble) {
        // FIXME: - ⚠️
        if !path.isEmpty { path = [] } //⚠️
        
        self.setNotification(of: bubble, for: .delete)
        
        //write empty string to the shared file that stores the mostRecentlyUsedBubbleRank
        let hasWidget = secretary.mostRecentlyUsedBubble == bubble.rank
        if hasWidget { secretary.setMostRecentlyUsedBubble(to: nil) }
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bubble.managedObjectContext?.perform {
            bubble.coordinator.update(for: .bubbleDelete)
            bubble.pairBubbleCellCoordinator.update(.user(.deleteBubble))
        }
        
        bContext.perform {
            let bBubble = bContext.object(with: objID) as! Bubble
            
            self.calManager.deleteEvent(with: bBubble.lastSession?.temporaryEventID)
            
            bContext.delete(bBubble) //13
            
            PersistenceController.shared.save(bContext) {
                delayExecution(self.delay) {
                    PersistenceController.shared.save()
                }
            }
        }
    } //9
    
    ///delete history. delete all sessions and pairs and make it brandNew
    func reset(_ bubble:Bubble) {
        
        setNotification(of: bubble, for: .reset)
        
        let objID = bubble.objectID
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            let thisBubble = bContext.object(with: objID) as! Bubble
            
            self.calManager.deleteEvent(with: thisBubble.lastSession?.temporaryEventID)
            
            thisBubble.created = Date()
            thisBubble.currentClock = thisBubble.initialClock
            
            //batch-delete all sessions
            let request:NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
            request.predicate = NSPredicate(format: "bubble.rank == %i", thisBubble.rank) //⚠️ 10
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            let storeResult = try? bContext.execute(batchDeleteRequest)
            
            //bContext saves -> viewContext sees the changes
            try? bContext.save()
            //no need for viewContext.save
            
            guard
                let deleteResult = storeResult as? NSBatchDeleteResult,
                let ids = deleteResult.result as? [NSManagedObjectID]
            else { fatalError() }
            
            let changes = [NSDeletedObjectsKey : ids]
            
            NSManagedObjectContext.mergeChanges(
                                fromRemoteContextSave: changes, into: [PersistenceController.shared.viewContext, PersistenceController.shared.bContext]) //12
            
            DispatchQueue.main.async {
                bubble.coordinator.update(for: .reset)
                bubble.pairBubbleCellCoordinator.update(.user(.reset))
            }
        }
    }
    
    //MoreOptionsView color change
    func changeColor(of bubble:Bubble, to newColor:String) {
        //don't do anything unless user changed color
        UserFeedback.singleHaptic(.medium)
        
        DispatchQueue.global().async {
            let bContext = PersistenceController.shared.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                thisBubble.color = newColor
                
                //save changes to CoreData using bContext and update UI
                PersistenceController.shared.save(bContext) {
                    let color = Color.bubbleColor(forName: thisBubble.color)
                    delayExecution(self.delay) {
                        bubble.coordinator.color = color
                    }
                }
            }
        }
    }
    
    // MARK: -
    func deleteSession(_ session:Session) {
        guard let bubble = session.bubble else { fatalError() }
        
        let bContext = PersistenceController.shared.bContext
        let bubbleID = bubble.objectID
        let sessionID = session.objectID
        
        bContext.perform {
            let thisBubble = bContext.object(with: bubbleID) as! Bubble
            let bSession = bContext.object(with: sessionID) as! Session
                        
            //1. set property here
            let isCurrentSession = (thisBubble.lastSession == bSession)
            
            let sessionEnded = session.isEnded
            self.calManager.deleteEvent(with: sessionEnded ? bSession.eventID : bSession.temporaryEventID)
            
            bContext.delete(bSession) //2. wait until context saves
            
            if isCurrentSession {
                thisBubble.currentClock = thisBubble.initialClock
                if thisBubble.isTimer{
                    self.setNotification(of: bubble, for: .closeSession)
                }
            }
            
            //3. use property here
            PersistenceController.shared.save(bContext) { //7
                delayExecution(self.delay) {
                    // try? PersistenceController.shared.viewContext.save()
                    if isCurrentSession {
                        bubble.coordinator.update(for: .currentSessionDelete)
                        bubble.pairBubbleCellCoordinator.update(.user(.deleteCurrentSession))
                    }
                }
            } //11
        }
    }
    
    func closeSession(_ bubble:Bubble) {
        if bubble.state == .brandNew {
            UserFeedback.singleHaptic(.soft)
            return
        }
        
        UserFeedback.singleHaptic(.heavy)
        
        setNotification(of: bubble, for: .closeSession)
        
        secretary.setAddNoteButton_bRank(to: nil) //1
        
        let objID = bubble.objectID
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            self.calManager.deleteEvent(with: bBubble.lastSession?.temporaryEventID)
            
            //reset bubble clock
            bBubble.currentClock = bBubble.initialClock
            bBubble.lastSession!.isEnded = true
            
            //when user ended session, was bubble still running?
            let bubbleIsRunning = (bBubble.lastPair!.pause == nil)
            
            //1.close lastPair and then compute durations for 2.lastPair and 3.lastSession
            if bubbleIsRunning {
                bBubble.lastPair!.pause = Date() //1
                bBubble.lastPair?.computeDuration(.atCloseSession) //2
                bBubble.lastSession?.computeDuration() //3
            }
            
            PersistenceController.shared.save(bContext) { //14
                self.createCalEventAndSave(for: bBubble)
                
                DispatchQueue.main.async { //15
                    bubble.coordinator.update(for: .closeSession)
                    bubble.pairBubbleCellCoordinator.update(.user(.closeSession))
                }
            }
        }
    }
    
    //delete BubbleSticky in List
    func deleteBubbleNote(_ savedNote:BubbleSavedNote?) {
        guard let savedNote = savedNote else { return }
        
        UserFeedback.singleHaptic(.soft)
        
        DispatchQueue.global().async {
            let bContext = PersistenceController.shared.bContext
            let objID = savedNote.objectID
            
            bContext.perform {
                let thisNote = bContext.object(with: objID) as! BubbleSavedNote
                bContext.delete(thisNote)
                PersistenceController.shared.save(bContext)
            }
        }
    }
    
    //delete PairSticky in List
    func deletePairNote(_ savedNote:PairSavedNote?) {
        guard let savedNote = savedNote else { return }
        
        UserFeedback.singleHaptic(.soft)
        
        let bContext = PersistenceController.shared.bContext
        let objID = savedNote.objectID
        
        bContext.perform {
            let thisNote = bContext.object(with: objID) as! PairSavedNote
            bContext.delete(thisNote)
            PersistenceController.shared.save(bContext)
        }
    }
    
    // TODO: To verify it works
    //delete PairSticky
    func deleteLapNote(of pair:Pair) {
        
        let objID = pair.objectID
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            let thisPair = PersistenceController.shared.grabObj(objID) as! Pair
            thisPair.note = nil
            
            PersistenceController.shared.save(bContext) {
                if let bubble = thisPair.session?.bubble {
                    CalendarManager.shared.updateEvent(.title(bubble))
                }
            }
        }
    }
    
    ///save to CoreData either bubble.note or pair.note
    func save(_ userInput:String, forObject object:NSManagedObject) {
        var note = userInput
        
        switch object.entity.name {
            case "Bubble":
                let bubble = object as! Bubble
                let objID = bubble.objectID
                
                PersistenceController.shared.bContext.perform {
                    note.removeWhiteSpaceAtBothEnds()
                    let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                    bBubble.name = note
                    bBubble.isNoteHidden = false
                    
                    //add new item to bubbleHistory
                    let newHistoryItem = BubbleSavedNote(context: bBubble.managedObjectContext!)
                    newHistoryItem.date = Date()
                    newHistoryItem.note = note
                    bBubble.addToHistory(newHistoryItem)
                    
                    PersistenceController.shared.save(bBubble.managedObjectContext) {
                        self.calManager.updateEvent(.title(bBubble))
                    }
                }
                
            case "Pair" :
                let pair = object as! Pair
                
                pair.note = note
                pair.isNoteHidden = false
                
                //add new item to bubbleHistory
                let pairSavedNote = PairSavedNote(context: pair.managedObjectContext!)
                pairSavedNote.date = Date()
                pairSavedNote.note = note
                pairSavedNote.bubble = pair.session?.bubble
                pair.addToHistory(pairSavedNote)
                
            default: return
        }
    }
    
    // MARK: - StartDelayBubble
    func removeDelay(for bubble:Bubble?)  {
        guard let bubble = bubble else { return }
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            guard
                let thisBubble = PersistenceController.shared.grabObj(objID) as? Bubble,
                let delayBubble = thisBubble.delayBubble
            else { return }
            
            thisBubble.delayBubble = nil //sdb removed from memory
            bContext.delete(delayBubble) //sdb removed from database
            
            DispatchQueue.main.async {
                bubble.delayBubble?.coordinator.update(.user(.pause))
                bubble.delayBubble?.coordinator = nil
            }
            PersistenceController.shared.save(bContext)
        }
    }
    
    func setDelay(_ delay:Float, for bubble:Bubble?) {
        guard let bubble = bubble, bubble.state != .running else { return }
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            if let sdb = thisBubble.delayBubble {
                //startDelay exists already
                //remove existing startDelay
                
                DispatchQueue.main.async {
                    bubble.delayBubble?.coordinator.update(.user(.reset))
                }
                thisBubble.delayBubble = nil
                bContext.delete(sdb)
            } else {
                
            }
            
            //create SDB
            let sdb = DelayBubble(context: bContext)
            sdb.created = Date()
            sdb.initialDelay = delay
            sdb.currentDelay = delay
            thisBubble.delayBubble = sdb
            
            PersistenceController.shared.save(bContext)
            
            DispatchQueue.main.async {
                let coordinator = bubble.delayBubble?.coordinator
                if let cancellabble = coordinator?.cancellable, !cancellabble.isEmpty {
                    coordinator?.update(.user(.reset))
                }
                coordinator?.valueToDisplay = delay
            }
        }
    } //19
    
    func toggleDelay(_ bubble:Bubble?) {
        guard
            let bubble = bubble,
            let sdb = bubble.delayBubble else { return }
        
        let bContext = PersistenceController.shared.bContext
        let objID = sdb.objectID
        
        UserFeedback.singleHaptic(.soft)
        
        bContext.perform {
            let theSDB = PersistenceController.shared.grabObj(objID) as! DelayBubble
            let currentDelay = theSDB.currentDelay
            let bubble = theSDB.bubble
            
            //figure out if it should start or pause
            switch theSDB.state {
                case .finished:
                    return
                    
                case .brandNew, .paused: //changes to .running
                    let pair = DelayBubblePair(context: theSDB.managedObjectContext!)
                    pair.start = Date()
                    theSDB.addToPairs(pair)
                    
                    self.setNotification(of: bubble, for: .delay(currentDelay))
                    
                    PersistenceController.shared.save(bContext) {
                        DispatchQueue.main.async { sdb.coordinator.update(.user(.start)) }
                    }
                    
                case .running: //changes to paused
                    let lastPair = theSDB.pairs_.last!
                    
                    //close lastPair and compute pair.duration
                    lastPair.pause = Date()
                    lastPair.duration = lastPair.computeDuration()
                    
                    //update sdb.totalDuration
                    theSDB.totalDuration += lastPair.duration
                    theSDB.currentDelay = theSDB.initialDelay - theSDB.totalDuration
                    
                    PersistenceController.shared.save(bContext) {
                        DispatchQueue.main.async { sdb.coordinator.update(.user(.pause)) }
                    }
            }
        }
    }
    
    func delete(_ timerDuration:TimerDuration) {
        let bContext = PersistenceController.shared.bContext
        let objID = timerDuration.objectID
        
        bContext.perform {
            let obj = PersistenceController.shared.grabObj(objID) as! TimerDuration
            bContext.delete(obj)
            PersistenceController.shared.save(bContext)
        }
    }
    
    func addToHistory(duration:Float) {
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            guard
                let history = try? bContext.fetch(TimerHistory.fetchRequest()).first
            else { return }
            
            let duplicates = history.allDurations.filter { $0.value == duration }
            
            if !duplicates.isEmpty {
                duplicates.first?.date = Date()
            } else {
                let timerDuration = TimerDuration(context: bContext)
                timerDuration.date = Date()
                timerDuration.value = duration
                history.add(timerDuration)
            }
            
            PersistenceController.shared.save(bContext)
        }
    }
    
    func updateTimerDurationsOrder(for value:Float, _ history:TimerHistory) {
        let durations = history.allDurations
        
        //no reason to change order if it's the first one
        if durations.first?.value == value { return }
        
        let timerDurationDuplicates = durations.filter { $0.value == value }
        
        if !timerDurationDuplicates.isEmpty {
            timerDurationDuplicates.first?.date = Date()
        }
    }
    
    enum SDBMode {
        case start
        case pause
    }
}

//MARK: - USER ASSIST
extension ViewModel {
    func addExampleLapNotes(_ pair:Pair) {
        let examples = [
            "🚲 Bike Ride", "🍏 Groceries", "❤️ Run",
            "🤓 Homework", "☕️ Break", "🐶 Walk", "🎾 Tennis"
        ]
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            examples.forEach {
                let newNote = PairSavedNote(context: bContext)
                newNote.note = $0
                newNote.date = Date()
            }
            
            PersistenceController.shared.save(bContext)
        }
    }
    
    func addExampleBubbleNotes(_ bubble:Bubble) {
        let examples = [
            "🌤️ Out", "🥇 Workout", "🤓 Work",
            "🏫 Learn", "🎤 Sing", "📚 Read", "🧘🏻 Meditate"
        ]
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            examples.forEach {
                let newNote = BubbleSavedNote(context: bContext)
                newNote.note = $0
                newNote.date = Date()
            }
            
            PersistenceController.shared.save(bContext)
        }
    }
    
    func addExampleBubble() {
        let bContext = PersistenceController.shared.bContext
        
        bContext.perform {
            let newBubble = Bubble(context: bContext)
            newBubble.created = Date()
            
            //stopwatch
            newBubble.initialClock = 0
            newBubble.currentClock = 0
            
            newBubble.color = "red1"
            newBubble.rank = Int64(UserDefaults.generateRank())
            
            newBubble.note_ = Names.testBubbleName
            newBubble.isNoteHidden = false
            
            PersistenceController.shared.save(bContext)
        }
    }
    
    func manageExample(_ bubble:Bubble) {
        if bubble.name == Names.testBubbleName {
            if path.isEmpty {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                withTransaction(transaction) {
                    path = [bubble]
                }
            }
        }
    }
}

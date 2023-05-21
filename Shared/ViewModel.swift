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

import Foundation
import SwiftUI
import Combine
import CoreData
import MyPackage
import WidgetKit

class ViewModel: ObservableObject {
    let localNotificationsManager = ScheduledNotificationsManager.shared
    let center = NotificationCenter.default
    
    private let delay:DispatchTime = .now() + 0.01
    
    private let secretary = Secretary.shared
    
    ///PersistanceController.shared
    private lazy var controller = PersistenceController.shared
            
    deinit { NotificationCenter.default.removeObserver(self) } //1
    
    private func notifyPath() {
        DispatchQueue.global().async {
            delayExecution(.now() + 0.005) {
                let info = ["detailViewVisible" : self.path.isEmpty ? false : true]
                NotificationCenter.default.post(name: .detailViewVisible,
                                                object: nil,
                                                userInfo: info) //3
            } //4
        }
    } //5
    
    // MARK: - Alerts
    @Published var path = [Bubble]() {didSet{
        notifyPath()
    }}
                
    // MARK: -
    var notesForPair: CurrentValueSubject<Pair?, Never> = .init(nil)
    
    var notesForBubble: CurrentValueSubject<Bubble?, Never> = .init(nil)
         
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
    func removeAddNoteButton(_ bubble:Bubble) {
        if let bubbleRank = secretary.addNoteButton_bRank, bubbleRank == Int(bubble.rank) {
            secretary.addNoteButton_bRank = nil
        }
    }
    
    func showMoreOptions(for bubble:Bubble) {
        secretary.moreOptionsBuble = bubble
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
        
        // FIXME: -
        PersistenceController.shared.save()
    }
    
    ///createds calendar events only if that bubble has calendar, otherwise it only saves to coredata
    private func createCalEventAndSave(for bubble:Bubble) {
        if !bubble.sessions_.isEmpty && bubble.hasCalendar {
            CalendarManager.shared.createNewEvent(for: bubble.lastSession)
            
            //display Cal Event Added to Calendar App confirmation to the user
            DispatchQueue.main.async {
                self.secretary.confirm_CalEventCreated = bubble.rank
                delayExecution(.now() + 3) { self.secretary.confirm_CalEventCreated = nil }
            }
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
    
    // MARK: - Observers [active/background]
    private func observe_ApplicationActive() {
        NotificationCenter.default.addObserver(forName: .didBecomeActive, object: nil, queue: nil) { [weak self] _ in
            self?.handleBecomeActive()
        }
    }
    
    private func observe_ApplicationBackground() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.handleEnterBackground()
        }
    }
    
    //refresh widget when app resigns active
    private func observe_AppResignActive() {
        let name = UIApplication.willResignActiveNotification
        center.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in
            self?.refreshWidgets()
        }
    }
    
    private func handleEnterBackground() { bubbleTimer(.pause) } //3
    
    private func handleBecomeActive() { bubbleTimer(.start) } //3
    
    // MARK: Observers
    private func observe_KillSDB() {
        center.addObserver(forName: .killSDB, object: nil, queue: nil) {[weak self] in
                        
            guard
                let rank = $0.userInfo?["rank"] as? Int64,
                let startCorrection = $0.userInfo?["startCorrection"] as? TimeInterval,
                let bubble = self?.bubble(for: Int(rank))
            else { fatalError() }
                        
            self?.removeStartDelay(for: bubble)
            
            self?.startPause(bubble, startDelayCompensation: startCorrection)
        }
    } //18
    
    private func observe_CreateTimer() {
        center.addObserver(forName: .createTimer, object: nil, queue: nil) { [weak self] in
            guard
                let color = $0.userInfo!["color"] as? String,
                let initialClock = $0.userInfo!["initialClock"] as? Int else { return }
            
            self?.createBubble(.timer(Float(initialClock)), color)
        }
    } //20
    
    ///Bubble.Coordinator.task() notifies if timer must finish
    private func observe_KillTimer() {
        center.addObserver(forName: .killTimer, object: nil, queue: nil) {[weak self] in
            let info = $0.userInfo
            
            let overspill = info!["overspill"] as! Float
            let bubbleRank = info!["rank"] as! Int64
            
            let bubble = self?.bubble(for: Int(bubbleRank))
            self?.killTimer(bubble, overspill)
        }
    }
    
    ///overspill is the elapsed time after timer has reached zero. overspill is either zero or negative negative
    private func killTimer(_ bubble:Bubble?, _ overspill:Float) {
        guard let bubble = bubble else { return }
                
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            let currentPair = thisBubble.lastPair
            
            //pair has a pauseDate and therefore duration can be computed
            currentPair!.pause = Date().addingTimeInterval(TimeInterval(overspill))
            currentPair!.computeDuration(.atPause)
            
            thisBubble.currentClock -= currentPair!.duration
            
            thisBubble.lastSession!.computeDuration()
            
            self.controller.save(bContext) {
                delayExecution(self.delay) {
                    bubble.coordinator.update(.finishTimer)
                    bubble.pairBubbleCellCoordinator.update(.user(.pause))
                }
            }
        }
    }
    
    // MARK: - Little Helpers
    var fiveSecondsBubble:Bubble? { bubble(for: secretary.addNoteButton_bRank) }
    
    func refreshOrdinaryBubbles() {
        let ranks = secretary.bubblesReport.colors.map { Int($0.id) }
        
        DispatchQueue.global().async {
            if !self.secretary.showFavoritesOnly {
                let bubbles = ranks.compactMap { self.bubble(for: $0) }
                bubbles.forEach { $0.coordinator.update(.showAll) }
            }
        }
    }
    
    private func refreshWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "Fused")
    }
    
    // MARK: - Init
    init() {
        observe_ApplicationActive()
        observe_ApplicationBackground()
        observe_AppResignActive()
        observe_KillSDB()
        observe_CreateTimer()
        observe_KillTimer()
        
        secretary.updateBubblesReport(.appLaunch)
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
    func createBubble(_ kind:Bubble.Kind,
                      _ color:String,
                      _ note:String? = nil) {
        
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
                let historyRequest = TimerHistory.fetchRequest()
                let history = try? bContext.fetch(historyRequest).first
                let newTimerDuration = TimerDuration(context: bContext)
                newTimerDuration.date = Date()
                newTimerDuration.duration = newBubble.initialClock
                history?.addToTimerDurations(newTimerDuration)
            }
            
            if let note = note {
                newBubble.note_ = note
                newBubble.isNoteHidden = false
            }
            self.controller.save(bContext)
            self.secretary.updateBubblesReport(.create(newBubble))
        }
    } //8
    
    func change(_ bubble:Bubble, to kind:Bubble.Kind) {
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        //pause bubble first and then change tracker
        if bubble.state == .running { startPause(bubble) }
        
        delayExecution(.now() + 0.1) {
            bContext.perform {
                let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                
                theBubble.lastSession?.handleTrackerID(.increment)
                
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
                        bubble.coordinator.updateCoordinatorOnTrackerChange()
                    }
                }
            }
        }
    }
    
    func deleteBubble(_ bubble:Bubble) {
        if !path.isEmpty { withAnimation(.easeInOut) { path = [] }}
        
        setupNotification(.delete, for: bubble)
        
        //write empty string to the shared file that stores the mostRecentlyUsedBubbleRank
        let hasWidget = secretary.mostRecentlyUsedBubble == bubble.rank
        if hasWidget { secretary.mostRecentlyUsedBubble = nil }
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bubble.managedObjectContext?.perform {
            bubble.coordinator.update(.user(.deleteBubble))
            bubble.pairBubbleCellCoordinator.update(.user(.deleteBubble))
        }
        
        bContext.perform {
            let thisBubble = bContext.object(with: objID) as! Bubble
            
            bContext.delete(thisBubble) //13
            self.secretary.updateBubblesReport(.delete(thisBubble))
            
            self.controller.save(bContext) {
                delayExecution(self.delay) {
                    self.controller.save()
                    
                    if self.secretary.showFavoritesOnly && self.secretary.bubblesReport.pinned == 1 {
                        self.secretary.showFavoritesOnly = false
                    } //17
                }
            }
        }
    } //9
    
    ///delta is always zero if user taps start. if user uses start delay, delta is not zero
    func startPause(_ bubble:Bubble, startDelayCompensation:TimeInterval? = nil) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  {
            secretary.showAlert_closeSession = true
            delayExecution(.now() + 3) { self.secretary.showAlert_closeSession = false }
            return
        }
        
        let startDelayCompensation = startDelayCompensation ?? 0
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        UserFeedback.singleHaptic(.heavy)
        
        switch bubble.state {
            case .brandNew: /* changes to .running */
                
                secretary.mostRecentlyUsedBubble = bubble.rank
                
                setupNotification(.start, for: bubble)
                
                bContext.perform {
                    let thisBubble = bContext.object(with: objID) as! Bubble
                    
                    //create newPair, newSession and add them to the newBubble
                    let newPair = Pair(context: bContext)
                    newPair.start = Date().addingTimeInterval(-startDelayCompensation)
                    
                    let newSession = Session(context: bContext)
                    newSession.created = Date().addingTimeInterval(-startDelayCompensation)
                    newSession.addToPairs(newPair)
                    
                    thisBubble.addToSessions(newSession)
                    //.....................................................
                    
                    //this also makes changes visible to the viewContext as well
                    self.controller.save(bContext) { //⚠️ no need to save viewContext
                        delayExecution(self.delay) { //UI stuff
                            
                            //refresh if it's a timer or bubble has a startDelay
                            let refresh = thisBubble.kind != .stopwatch || startDelayCompensation != 0
                            
                            bubble.coordinator.update(.user(.start), refresh: refresh)
                            bubble.pairBubbleCellCoordinator.update(.user(.start))
                            
                            //1 both
                            self.secretary.addNoteButton_bRank = nil //clear first
                            self.secretary.addNoteButton_bRank = Int(bubble.rank)
                            
                            delayExecution(.now() + 0.3) {
                                self.secretary.pairBubbleCellNeedsDisplay.toggle()
                            }
                        }
                    }
                }
                
            case .paused:  /* changes to running */
                
                secretary.mostRecentlyUsedBubble = bubble.rank
                
                setupNotification(.start, for: bubble)
                
                bContext.perform {
                    let thisBubble = bContext.object(with: objID) as! Bubble
                    
                    //create new pair, add it to currentSession
                    let newPair = Pair(context: bContext)
                    newPair.start = Date().addingTimeInterval(-startDelayCompensation)
                    
                    thisBubble.lastSession?.handleTrackerID(.assign(newPair))
                    
                    thisBubble.lastSession?.addToPairs(newPair)
                    
                    //this also makes changes visible to the viewContext as well
                    self.controller.save(bContext) { //⚠️ no need to save vContext
                        delayExecution(self.delay) { //UI stuff
                            bubble.coordinator.update(.user(.start))
                            bubble.pairBubbleCellCoordinator.update(.user(.start))
                            
                            //1 both
                            self.secretary.addNoteButton_bRank = nil //clear first
                            self.secretary.addNoteButton_bRank = Int(bubble.rank)
                            
                            delayExecution(.now() + 0.3) {
                                self.secretary.pairBubbleCellNeedsDisplay.toggle()
                            }
                        }
                    }
                }
                
            case .running: /* changes to .paused */
                setupNotification(.pause, for: bubble)
                
                bContext.perform {
                    let thisBubble = self.controller.grabObj(objID) as! Bubble
                    let currentPair = thisBubble.lastPair
                    currentPair!.pause = Date()
                    
                    currentPair!.computeDuration(.atPause)
                    
                    let isTimer = thisBubble.kind != .stopwatch
                    
                    if isTimer {
                        thisBubble.currentClock -= currentPair!.duration
                    } else {
                        thisBubble.currentClock += currentPair!.duration
                    }
                    
                    thisBubble.lastSession!.computeDuration()
                    self.controller.save(bContext) {
                        delayExecution(self.delay) {
                            bubble.coordinator.update(.user(.pause))
                            bubble.pairBubbleCellCoordinator.update(.user(.pause))
                            
                            //remove only that
                            if self.secretary.addNoteButton_bRank == Int(bubble.rank) { self.secretary.addNoteButton_bRank = nil
                            } //1
                        }
                    }
                }
                
            case .finished:
                return
        }
    }
    
    ///delete history. delete all sessions and pairs and make it brandNew
    func reset(_ bubble:Bubble) {
        guard !bubble.sessions_.isEmpty else { return }
        
        setupNotification(.reset, for: bubble)
        
        DispatchQueue.global().async {
            let objID = bubble.objectID
            let bContext = self.controller.bContext
            
            bContext.perform {
                let thisBubble = bContext.object(with: objID) as! Bubble
                
                thisBubble.created = Date()
                thisBubble.currentClock = thisBubble.initialClock
                
                //batch-delete all sessions
                let request:NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
                request.predicate = NSPredicate(format: "bubble.rank == %i", thisBubble.rank) //⚠️ 10
                
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                batchDeleteRequest.resultType = .resultTypeObjectIDs
                
                let result = try? bContext.execute(batchDeleteRequest)
                
                try? bContext.save()
                DispatchQueue.main.async {
                    try? bubble.managedObjectContext?.save()
                }
                
                guard
                    let deleteResult = result as? NSBatchDeleteResult,
                    let ids = deleteResult.result as? [NSManagedObjectID]
                else { fatalError() }
                
                let changes = [NSDeletedObjectsKey : ids]
                                
                delayExecution(self.delay) {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: changes, into: [self.controller.viewContext]) //12
                    bubble.coordinator.update(.user(.reset))
                    bubble.pairBubbleCellCoordinator.update(.user(.reset))
                }
            }
        }
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        
        let objID = bubble.objectID
        let bContext = self.controller.bContext
        
        bContext.perform {
            let thisBubble = bContext.object(with: objID) as! Bubble
            
            thisBubble.hasCalendar.toggle()
            
            //create events for this bubbble
            if thisBubble.hasCalendar { CalendarManager.shared.bubbleToEventify = thisBubble }
            
            self.controller.save(bContext)
        }
    }
    
    //MoreOptionsView color change
    func changeColor(of bubble:Bubble, to newColor:String) {
        //don't do anything unless user changed color
        UserFeedback.singleHaptic(.medium)
        
        DispatchQueue.global().async {
            let bContext = self.controller.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let thisBubble = self.controller.grabObj(objID) as! Bubble
                thisBubble.color = newColor
                
                self.secretary.updateBubblesReport(.colorChange(thisBubble))
                
                //save changes to CoreData using bContext and update UI
                self.controller.save(bContext) {
                    let color = Color.bubbleColor(forName: thisBubble.color)
                    delayExecution(self.delay) {
                        bubble.coordinator.color.send(color)
                    }
                }
            }
        }
    }
    
    func togglePin(_ bubble:Bubble) {
        if secretary.bubblesReport.ordinary == 1 && !bubble.isPinned {
            return
        }
        
        let bContext = self.controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            thisBubble.isPinned.toggle()
            self.secretary.updateBubblesReport(.pin(thisBubble))
            
            if self.secretary.bubblesReport.pinned == 0 && self.secretary.showFavoritesOnly {
                //if no pinned bubbles and ordinary buubles are hidden, show all bubbles
                DispatchQueue.main.async {
                    withAnimation {
                        self.secretary.showFavoritesOnly = false
                    }
                }
            }
            self.controller.save(bContext)
        }
    }
    
    // MARK: -
    func deleteSession(_ session:Session) {
        guard let bubble = session.bubble else { fatalError() }
        
        let bContext = self.controller.bContext
        let bubbleID = bubble.objectID
        let sessionID = session.objectID
        
        bContext.perform {
            let thisBubble = bContext.object(with: bubbleID) as! Bubble
            let thisSession = bContext.object(with: sessionID) as! Session
            
            //1. set property here
            let isCurrentSession = (thisBubble.lastSession == thisSession)
            
            bContext.delete(thisSession) //2. wait until context saves
            
            if isCurrentSession { thisBubble.currentClock = thisBubble.initialClock }
            
            //3. use property here
            PersistenceController.shared.save(bContext) { //7
                delayExecution(self.delay) {
                    // try? PersistenceController.shared.viewContext.save()
                    if isCurrentSession {
                        bubble.coordinator.update(.user(.deleteCurrentSession))
                        bubble.pairBubbleCellCoordinator.update(.user(.deleteCurrentSession))
                    }
                }
            } //11
        }
    }
    
    func endSession(_ bubble:Bubble) {
        if bubble.state == .brandNew { return }
        
        setupNotification(.endSession, for: bubble)
        
        secretary.addNoteButton_bRank = nil //1
        
        let objID = bubble.objectID
        let bContext = controller.bContext
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            
            //reset bubble clock
            thisBubble.currentClock = thisBubble.initialClock
            thisBubble.lastSession!.isEnded = true
            
            //when user ended session, was bubble still running?
            let bubbleIsRunning = (thisBubble.lastPair!.pause == nil)
            
            //1.close lastPair and then compute durations for 2.lastPair and 3.lastSession
            if bubbleIsRunning {
                thisBubble.lastPair!.pause = Date() //1
                thisBubble.lastPair?.computeDuration(.atEndSession) //2
                thisBubble.lastSession?.computeDuration() //3
            }
            
            self.controller.save(bContext) { //14
                self.createCalEventAndSave(for: thisBubble)
                delayExecution(self.delay) { //15
                    bubble.coordinator.update(.user(.endSession))
                    bubble.pairBubbleCellCoordinator.update(.user(.endSession))
                }
            }
        }
    }
    
    //delete BubbleSticky in List
    func deleteBubbleNote(_ savedNote:BubbleSavedNote) {
        DispatchQueue.global().async { [weak self] in
            
            guard let self = self else { return }
            
            let bContext = self.controller.bContext
            let objID = savedNote.objectID
            
            bContext.perform {
                let thisNote = bContext.object(with: objID) as! BubbleSavedNote
                bContext.delete(thisNote)
                self.controller.save(bContext)
            }
        }
    }
    
    //delete PairSticky in List
    func deletePairNote(_ savedNote:PairSavedNote) {
        DispatchQueue.global().async {
            let bContext = self.controller.bContext
            let objID = savedNote.objectID
            
            bContext.perform {
                let thisNote = bContext.object(with: objID) as! PairSavedNote
                bContext.delete(thisNote)
                self.controller.save(bContext)
            }
        }
    }
    
    // TODO: To verify it works
    //delete BubbleSticky
    func deleteStickyNote(for bubble:Bubble) {
        let objID = bubble.objectID
        let bContext = controller.bContext
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            thisBubble.note = nil
            
            self.controller.save(bContext) {
                delayExecution(self.delay) {
                    bubble.managedObjectContext?.perform {
                        CalendarManager.shared.updateExistingEvent(.title(bubble))
                    }
                }
            }
        }
    }
    
    //delete PairSticky
    func deleteStickyNote(for pair:Pair) {
        
        let objID = pair.objectID
        let bContext = controller.bContext
        
        bContext.perform {
            let thisPair = self.controller.grabObj(objID) as! Pair
            thisPair.note = nil
            
            self.controller.save(bContext) {
                delayExecution(self.delay) {
                    pair.managedObjectContext?.perform {
                        CalendarManager.shared.updateExistingEvent(.notes(pair.session!))
                    }
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
                
                bubble.managedObjectContext?.perform {
                    note.removeWhiteSpaceAtBothEnds()
                    let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                    theBubble.note = note
                    theBubble.isNoteHidden = false
                    
                    //add new item to bubbleHistory
                    let newHistoryItem = BubbleSavedNote(context: theBubble.managedObjectContext!)
                    newHistoryItem.date = Date()
                    newHistoryItem.note = note
                    theBubble.addToHistory(newHistoryItem)
                    
                    self.controller.save(bubble.managedObjectContext)
                    
                    delayExecution(self.delay) {
                        CalendarManager.shared.updateExistingEvent(.title(bubble))
                    }
                }
                
            case "Pair" :
                let pair = object as! Pair
                
                    //it's bContext since pair is coming from PairStickyNoteLost.saveNoteToCoredata
                pair.managedObjectContext?.perform {
                    note.removeWhiteSpaceAtBothEnds()
                    
                    pair.note = note
                    pair.isNoteHidden = false
                    
                    //add new item to bubbleHistory
                    let newHistoryItem = PairSavedNote(context: pair.managedObjectContext!)
                    newHistoryItem.date = Date()
                    newHistoryItem.note = note
                    pair.addToHistory(newHistoryItem)
                    
                    self.controller.save(pair.managedObjectContext)
                    
                    delayExecution(self.delay) {
                        CalendarManager.shared.updateExistingEvent(.notes(pair.session!))
                    }
                }
                
            default: return
        }
    }
    
    // MARK: - StartDelayBubble
    func removeStartDelay(for bubble:Bubble?)  {
        guard
            let bubble = bubble,
            bubble.startDelayBubble != nil
        else { return }
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            bContext.delete(thisBubble.startDelayBubble!) //sdb removed from database
            
            DispatchQueue.main.async {
                bubble.startDelayBubble?.coordinator.update(.user(.pause))
                bubble.startDelayBubble?.coordinator = nil
            }
            thisBubble.startDelayBubble = nil //sdb removed from memory
            self.controller.save(bContext)
        }
    }
    
    func setStartDelay(_ delay:Float, for bubble:Bubble?) {
        guard let bubble = bubble, bubble.state != .running else {
            return
        }
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            
            if let sdb = thisBubble.startDelayBubble {
                //startDelay exists already
                //remove existing startDelay
                
                DispatchQueue.main.async {
                    bubble.startDelayBubble?.coordinator.update(.user(.reset))
                }
                thisBubble.startDelayBubble = nil
                bContext.delete(sdb)
            }
            
            //create SDB
            let sdb = StartDelayBubble(context: bContext)
            sdb.created = Date()
            sdb.initialClock = delay
            sdb.currentClock = delay
            thisBubble.startDelayBubble = sdb
            
            self.controller.save(bContext)
            
            DispatchQueue.main.async {
                let coordinator = bubble.startDelayBubble?.coordinator
                if let cancellabble = coordinator?.cancellable, !cancellabble.isEmpty {
                    coordinator?.update(.user(.reset))
                }
                coordinator?.valueToDisplay = delay
            }
        }
    } //19
    
    func toggleSDBubble(_ bubble:Bubble?) {
        guard
            let bubble = bubble,
            let sdb = bubble.startDelayBubble else { return }
        
        let bContext = controller.bContext
        let objID = sdb.objectID
        
        bContext.perform {
            let theSDB = self.controller.grabObj(objID) as! StartDelayBubble
            
            //figure out if it should start or pause
            switch theSDB.state {
                case .finished:
                    return
                    
                case .brandNew, .paused: //changes to .running
                    let pair = SDBPair(context: theSDB.managedObjectContext!)
                    pair.start = Date()
                    theSDB.addToPairs(pair)
                    
                    self.controller.save(bContext) {
                        DispatchQueue.main.async { sdb.coordinator.update(.user(.start)) }
                    }
                    
                case .running: //changes to paused
                    let lastPair = theSDB.pairs_.last!
                    
                    //close lastPair and compute pair.duration
                    lastPair.pause = Date()
                    lastPair.duration = lastPair.computeDuration()
                    
                    //update sdb.totalDuration
                    theSDB.totalDuration += lastPair.duration
                    theSDB.currentClock = theSDB.initialClock - theSDB.totalDuration
                                                                                
                    self.controller.save(bContext) {
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
        
    enum SDBMode {
        case start
        case pause
    }
}

// MARK: - Local Notifications
extension ViewModel {
    enum NotificationSituation {
        case endSession
        case start
        case pause
        case delete
        case reset
    }
    
    ///before ct.state changed!!!
    func setupNotification(_ situation:NotificationSituation, for timer:Bubble) {
        guard timer.isTimer else { return }
        
        switch situation {
            case .start:
                guard timer.state == .paused || timer.state == .brandNew else { return }
                localNotificationsManager.scheduleNotification(for: timer, atSecondsFromNow: TimeInterval(timer.currentClock), isSnooze: false)
                
            case .delete, .reset, .endSession, .pause:
                if timer.state == .running {
                    localNotificationsManager.cancelScheduledNotification(for: timer)
                }
        }
    }
}

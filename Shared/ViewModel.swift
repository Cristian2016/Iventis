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

import Foundation
import SwiftUI
import Combine
import CoreData
import MyPackage

class ViewModel: ObservableObject {
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
    @Published var path = [Bubble]() {didSet{ notifyPath() }}
                
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
    
    func toggleSDBStart(_ sdb:StartDelayBubble) {
        UserFeedback.singleHaptic(.heavy)
        sdb.toggleStart()
    }
    
    func showMoreOptions(for bubble:Bubble) {
        //set Published property triggers UI update
        //MoreOptionsView displayed
        secretary.theOneAndOnlyEditedSDB = bubble.sdb
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
    
    ///createds calendar events only if that bubble has calendar, otherwise it only saves to coredata
    private func createCalendarEventIfRequiredAndSaveToCoreData(for bubble:Bubble) {
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
    
    // MARK: - Observers
    
    private func observe_ApplicationActive() {
        NotificationCenter.default.addObserver(forName: .appActive, object: nil, queue: nil) { [weak self] _ in
            self?.handleBecomeActive()
        }
    }
    
    private func observe_ApplicationBackground() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.handleEnterBackground()
        }
    }
    
    private func handleEnterBackground() { bubbleTimer(.pause) } //3
    
    private func handleBecomeActive() { bubbleTimer(.start) } //3
    
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
    
    // MARK: - Init
    init() {
        observe_ApplicationActive()
        observe_ApplicationBackground()
        observe_delayReachedZero_Notification()
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

// MARK: - Bubble operations
extension ViewModel {
    // MARK: - User Intents
    func createBubble(_ kind:Bubble.Kind,
                      _ color:String,
                      _ note:String? = nil) {
        
        DispatchQueue.global().async {
            let bContext = PersistenceController.shared.bContext
            
            bContext.perform {
                let newBubble = Bubble(context: bContext)
                newBubble.created = Date()
                newBubble.kind = kind
                switch kind {
                    case .timer(let initialClock):
                        newBubble.initialClock = initialClock
                    default:
                        newBubble.initialClock = 0
                }
                
                newBubble.color = color
                newBubble.rank = Int64(UserDefaults.generateRank())
                
                // FIXME: - no more StartDelayBubble!
                let sdb = StartDelayBubble(context: newBubble.managedObjectContext!)
                newBubble.sdb = sdb
                if let note = note {
                    newBubble.note_ = note
                    newBubble.isNoteHidden = false
                }
                  
                do {
                    try bContext.save()
                } catch let error {
                    print("pula CoreData \(error.localizedDescription)")
                }
            }
        }
    }
    ///delta is always zero if user taps start. if user uses start delay, delta is not zero
    func toggleBubbleStart(_ bubble:Bubble, delta:TimeInterval? = nil) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  { return }
        removeDelay(for: bubble)
        
        let startDelayCompensation = delta ?? 0
        
        switch bubble.state {
            case .brandNew: /* changes to .running */
                
                let bContext = PersistenceController.shared.bContext
                let objID = bubble.objectID
                
                bContext.perform {
                    let thisBubble = bContext.object(with: objID) as! Bubble
                    
                    let newSession = Session(context: thisBubble.managedObjectContext!)
                    newSession.created = Date().addingTimeInterval(startDelayCompensation)
                    
                    let newPair = Pair(context: thisBubble.managedObjectContext!)
                    newPair.start = Date().addingTimeInterval(startDelayCompensation)
                    newSession.addToPairs(newPair)
                    
                    thisBubble.addToSessions(newSession)
                    
                    try? bContext.save() //⚠️
                    
                    DispatchQueue.main.async {
                        //repetitive chunk of code ⚠️
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
                
            case .paused:  /* changes to running */
                let bContext = PersistenceController.shared.bContext
                let objID = bubble.objectID
                
                bContext.perform {
                    let thisBubble = bContext.object(with: objID) as! Bubble
                    
                    //create new pair, add it to currentSession
                    let newPair = Pair(context: thisBubble.managedObjectContext!)
                    newPair.start = Date().addingTimeInterval(startDelayCompensation)
                    thisBubble.lastSession?.addToPairs(newPair)
                    
                    try? bContext.save()
                    
                    DispatchQueue.main.async {
                        //repetitive chunk of code ⚠️
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
                
            case .running: /* changes to .paused */
                let bContext = PersistenceController.shared.bContext
                let objID = bubble.objectID
                
                bContext.perform {
                    let thisBubble = self.controller.grabObj(objID) as! Bubble
                    let currentPair = thisBubble.lastPair
                    currentPair?.pause = Date()
                    
                    currentPair?.computeDuration(.atPause) {
                        thisBubble.currentClock += currentPair!.duration
                        
                        thisBubble.lastSession?.computeDuration { //completion handler
                            try? bContext.save()
                            
                            DispatchQueue.main.async {
                                bubble.coordinator.update(.user(.pause))
                                bubble.pairBubbleCellCoordinator.update(.user(.pause))
                                
                                //remove only that
                                if self.secretary.addNoteButton_bRank == Int(bubble.rank) { self.secretary.addNoteButton_bRank = nil
                                } //1
                            }
                        }
                    }
                }
                
            case .finished: return
        }
    }
    
    ///delete history. delete all sessions and pairs and make it brandNew
    func reset(_ bubble:Bubble) {
        guard !bubble.sessions_.isEmpty else { return }
        
        DispatchQueue.global().async {
            let objID = bubble.objectID
            let bContext = self.controller.bContext
            
            bContext.perform {
                let thisBubble = bContext.object(with: objID) as! Bubble
                
                thisBubble.created = Date()
                thisBubble.currentClock = thisBubble.initialClock
                
                //batch-delete all sessions
                let request:NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
                
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                batchDeleteRequest.resultType = .resultTypeObjectIDs
                
                do {
                    let result = try bContext.execute(batchDeleteRequest)
                    
                    guard
                        let deleteResult = result as? NSBatchDeleteResult,
                        let ids = deleteResult.result as? [NSManagedObjectID]
                    else { return }
                    
                    let changes = [NSDeletedObjectsKey : ids]
                    
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: changes, into: [self.controller.viewContext]
                    )
                    
                    try bContext.save()
                    
                    DispatchQueue.main.async {
                        bubble.coordinator.update(.user(.reset))
                        bubble.pairBubbleCellCoordinator.update(.user(.reset))
                    }
                    
                } catch let error {
                    print("CoreData pula \(error.localizedDescription)")
                }
            }
        }
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        DispatchQueue.global().async {
            let objID = bubble.objectID
            let bContext = self.controller.bContext
            
            bContext.perform {
                let thisBubble = bContext.object(with: objID) as! Bubble
                
                thisBubble.hasCalendar.toggle()
                
                //create events for this bubbble
                if thisBubble.hasCalendar { CalendarManager.shared.bubbleToEventify = thisBubble }
                
                do {
                    try bContext.save()
                } catch let error {
                    print("CoreData error \(error.localizedDescription)")
                }
            }
        }
    }
    
    //MoreOptionsView color change
    func changeColor(of bubble:Bubble, to newColor:String) {
        //don't do anything unless user changed color
        if bubble.color == newColor { return }
        UserFeedback.singleHaptic(.medium)
        
        DispatchQueue.global().async {
            let bContext = self.controller.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let thisBubble = self.controller.grabObj(objID) as! Bubble
                thisBubble.color = newColor
                try? bContext.save()
                
                let color = Color.bubbleColor(forName: thisBubble.color)
                DispatchQueue.main.async {
                    bubble.coordinator.colorPublisher.send(color)
                }
            }
        }
    }
    
    func togglePin(_ bubble:Bubble) {
//        if bubble.isPinned, Secretary.shared.pinnedBubblesCount == 1 {
//            secretary.showFavoritesOnly = false
//        }
        
        DispatchQueue.global().async {
            let bContext = self.controller.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let thisBubble = self.controller.grabObj(objID) as! Bubble
                thisBubble.isPinned.toggle()
                try? bContext.save()
            }
        }
    }
    
    // MARK: -
    func deleteBubble(_ bubble:Bubble) {
        //if unpinned are hidden & bubble to delete is pinned and pinned section has only one item, unhide unpinned
        //        if secretary.showFavoritesOnly, Secretary.shared.pinnedBubblesCount == 1 {
        //            secretary.showFavoritesOnly = false
        //        }
        if !path.isEmpty { path = [] }
        
        //⚠️ do I really need to set to nil?
        //        bubble.coordinator.update(.user(.deleteBubble))
        //        bubble.pairBubbleCellCoordinator.update(.user(.deleteBubble))
        
        DispatchQueue.main.async {
            let bContext = self.controller.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let thisBubble = bContext.object(with: objID) as! Bubble
                bContext.delete(thisBubble)
                
                try? bContext.save()
            }
        }
    }
    
    func deletePair(_ pair:Pair?) {
        guard let pair = pair else { return }
        
        DispatchQueue.global().async {
            let objID = pair.objectID
            let bContext = self.controller.bContext
            
            bContext.perform {
                let thisPair = bContext.object(with: objID) as! Pair
                bContext.delete(thisPair)
                try? bContext.save()
            }
        }
    }
    
    func deleteSession(_ session:Session) {
        guard let bubble = session.bubble else { fatalError() }
        
        DispatchQueue.global().async {
            let bContext = self.controller.bContext
            let bubbleID = bubble.objectID
            let sessionID = session.objectID
            
            bContext.perform {
                let thisBubble = bContext.object(with: bubbleID) as! Bubble
                let thisSession = bContext.object(with: sessionID) as! Session
                
                //set this property and use it after context was saved
                let isCurrentSession = thisBubble.lastSession == thisSession
                
                bContext.delete(thisSession)
                
                do {
                    try bContext.save()
                    
                    if isCurrentSession {
                        thisBubble.currentClock = thisBubble.initialClock
                        
                        DispatchQueue.main.async {
                            bubble.coordinator.update(.user(.deleteCurrentSession))
                            bubble.pairBubbleCellCoordinator.update(.user(.deleteCurrentSession))
                        }
                    }
                } //7
                catch let error { print(error.localizedDescription) }
            }
        }
    }
    
    func endSession(_ bubble:Bubble) {
        //make sure no startDelayBubble displayed at this point
        removeDelay(for: bubble)
        
        secretary.addNoteButton_bRank = nil //1
        
        let objID = bubble.objectID
        let bContext = controller.bContext
        if bubble.state == .brandNew { return }
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as! Bubble
            
            //reset bubble clock
            thisBubble.currentClock = thisBubble.initialClock
            //mark session as ended
            thisBubble.lastSession?.isEnded = true
            
            let bubbleWasStillRunningWhenSessionWasEnded = thisBubble.lastPair!.pause == nil
            
            if bubbleWasStillRunningWhenSessionWasEnded {
                thisBubble.lastPair!.pause = Date() //close last pair
                
                //compute lastPair duration first [on background thread 🔴]
                thisBubble.lastPair?.computeDuration(.atEndSession) {
                    thisBubble.lastSession?.computeDuration {
                        self.createCalendarEventIfRequiredAndSaveToCoreData(for: thisBubble)
                    }
                }
            }
            else { self.createCalendarEventIfRequiredAndSaveToCoreData(for: thisBubble) }
            
            try? bContext.save() //⚠️ from this moment on, viewContext can see the changes
            
            DispatchQueue.main.async {
                bubble.coordinator.update(.user(.endSession))
                bubble.pairBubbleCellCoordinator.update(.user(.endSession))
            }
        }
    }
    
    //delete BubbleSticky in List
    func deleteBubbleNote(_ savedNote:BubbleSavedNote) {
        DispatchQueue.global().async {
            let bContext = self.controller.bContext
            let objID = savedNote.objectID
            
            bContext.perform {
                let thisNote = bContext.object(with: objID) as! BubbleSavedNote
                bContext.delete(thisNote)
                try? bContext.save()
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
                try? bContext.save()
            }
        }
    }
    
    // TODO: To verify it works
    //delete BubbleSticky
    func deleteStickyNote(for bubble:Bubble) {
        bubble.managedObjectContext?.perform {
            bubble.note = nil
            CalendarManager.shared.updateExistingEvent(.title(bubble))
            try? bubble.managedObjectContext?.save()
        }
    }
    
    //delete PairSticky
    func deleteStickyNote(for pair:Pair) {
        pair.managedObjectContext?.perform {
            pair.note = nil
            CalendarManager.shared.updateExistingEvent(.notes(pair.session!))
            try? pair.managedObjectContext?.save()
        }
    }
}

//
//  MoreOptionsViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.07.2023.
//1 might change in future builds, so that it will not need an intial value like that
// @Observable requires property 'bubble' to have an initial value (from macro 'Observable')
//2 //grab background context Bubble object
//make sure its startDelay is set
//set bBubble.sdb to nil
//ask background context to delete the bubble
//back on mainQueue do visual updates
//save changes on bContext
//1 example user taps More Button and that sets 1 to whatever bubble (bubbleCell.bubble)

import Foundation
import Observation
import MyPackage
import SwiftUI

///The new vieModel that will eventually replace old ViewModel
@Observable
class ViewModel {
    let secretary = Secretary()
    let center = NotificationCenter.default
    
    internal var bubbleTimerIsRunning = false
        
    var path = [Bubble]() {
        didSet {
            SmallHelpOverlay.Model.shared.topmostView(oldValue.isEmpty ? .detail : .bubbleList)
            notifyPathChanged()
        }
    }
    
    var notes_Bubble:Bubble?
    
    //MARK: - PairSavedNotes
    private(set) var pairNotes:(Pair?, [PairSavedNote])?
    
    func pairNotes(_ state:BoolState) {
        switch state {
            case .hide: pairNotes = nil
            case .show(let pair):
                setPairNotes(for: pair)
        }
    }
    
    private func setPairNotes(for pair:Pair?) {
        DispatchQueue.global().async {
            PersistenceController.shared.bContext.perform {
                let request = PairSavedNote.fetchRequest()
                request.sortDescriptors = [.init(keyPath: \PairSavedNote.date, ascending: false)]
                
                if let objs = try? PersistenceController.shared.bContext.fetch(request) {
                    
                    var thisBucket = [PairSavedNote]()
                    var otherBucket = [PairSavedNote]()
                    
                    objs.forEach { note in
                        note.bubble?.rank == pair?.session?.bubble?.rank ? thisBucket.append(note) : otherBucket.append(note)
                    }
                    
                    let sorted = thisBucket + otherBucket
                    DispatchQueue.main.async {
                        self.pairNotes = (pair, sorted)
                    }
                }
            }
        }
    }
    
    enum BoolState {
        case show(Pair?)
        case hide
    }
    
    func selectExisting(_ note:PairSavedNote, _ initialNote:String, _ pair:Pair) {
        
        UserFeedback.singleHaptic(.light)
        
        let bContext = PersistenceController.shared.bContext
        let objID = pair.objectID
        let objID1 = note.objectID
        
        bContext.perform {
            let bPair = PersistenceController.shared.grabObj(objID) as? Pair
            let bNote = PersistenceController.shared.grabObj(objID1) as? PairSavedNote
            
            //set pair.note and show note
            bPair?.note = note.note
            bPair?.isNoteHidden = false
            
            bNote?.bubble = bPair?.session?.bubble
            note.date = Date()
            
            PersistenceController.shared.save(bContext) {
                if let bBubble = bPair?.session?.bubble {
                    self.calManager.updateEvent(.title(bBubble))
                }
            }
        }
    }
    
    func selectExisting(_ note:BubbleSavedNote, _ initialNote:String, _ bubble:Bubble) {
//        if initialNote == note.note { return }
        
        UserFeedback.singleHaptic(.light)
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        let noteObjID = note.objectID
        
        bContext.perform {
            guard let bBubble = PersistenceController.shared.grabObj(objID) as? Bubble else { return }
            let bNote = PersistenceController.shared.grabObj(noteObjID) as? BubbleSavedNote
            
            //set pair.note and show note
            bBubble.name = note.note
            bBubble.isNoteHidden = false
            
            note.date = Date()
            
            bNote?.bubble = bBubble
            
            PersistenceController.shared.save(bContext) {
                self.calManager.updateEvent(.title(bBubble))
            }
        }
    }
    
    //MARK: -
    private func notifyPathChanged() {
        DispatchQueue.global().async {
            delayExecution(.now() + 0.005) {
                let info = ["detailViewVisible" : self.path.isEmpty ? false : true]
                self.center.post(name: .detailViewVisible, object: nil, userInfo: info) //3
            } //4
        }
    } //5
    
    // MARK: - Init
    init() {
        observe_KillDelayBubble()
        observe_CreateTimer()
        observe_EditTimerDuration()
        observe_KillTimer()
    }
    
    let localNotificationsManager = ScheduledNotificationsManager.shared
    let calManager = CalendarManager.shared
    
    let delay:DispatchTime = .now() + 0.01
    
    ///PersistanceController.shared
    deinit { center.removeObserver(self) } //1
    
    // MARK: - background Timers
    var bubbleTimer = BubbleTimer()
    
    var moreOptionsSheetBubble:Bubble? { didSet {
        if moreOptionsSheetBubble != nil {
            SmallHelpOverlay.Model.shared.topmostView(.moreOptions)
        } else {
            SmallHelpOverlay.Model.shared.topmostView(path.isEmpty ? .bubbleList : .detail)
        }
    }}
    
    var userEnteredStartDelay = Float(0)
    
    ///sets self to its initial state
    func reset() {
        moreOptionsSheetBubble = nil
        delayExecution(.now() + 0.5) { self.userEnteredStartDelay = 0 }
    }
    
    func removeStartDelay() {
        guard let bubble = moreOptionsSheetBubble else { return }
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        userEnteredStartDelay = 0
        
        bContext.perform {//2
            guard
                let thisBubble = controller.grabObj(objID) as? Bubble,
                let startDelayBubble = thisBubble.delayBubble
            else { return }
            
            thisBubble.delayBubble = nil //sdb removed from memory
            bContext.delete(startDelayBubble) //sdb removed from database
            
            DispatchQueue.main.async {
                bubble.delayBubble?.coordinator.update(.user(.pause))
                bubble.delayBubble?.coordinator = nil
            }
            
            controller.save(bContext)
        }
    }
    
    func saveStartDelay(_ bubble:Bubble) {
        //it uses MoreOptions.bubble
        
        let initialStartDelay = bubble.delayBubble?.initialDelay ?? 0
        
        //make sure 1.user entered start delay and 2. is different from existing start delay
        guard userEnteredStartDelay != 0 && userEnteredStartDelay != initialStartDelay
        else { return }
        
        UserFeedback.singleHaptic(.heavy)
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = controller.grabObj(objID) as? Bubble
            
            if let sdb = thisBubble?.delayBubble {
                //startDelay exists already
                //remove existing startDelay
                
                DispatchQueue.main.async {
                    bubble.delayBubble?.coordinator.update(.user(.reset))
                }
                thisBubble?.delayBubble = nil
                bContext.delete(sdb)
            }
            
            //create SDB
            let sdb = DelayBubble(context: bContext)
            sdb.created = Date()
            sdb.initialDelay = self.userEnteredStartDelay
            sdb.currentDelay = sdb.initialDelay
            thisBubble?.delayBubble = sdb
            
            controller.save(bContext)
            
            DispatchQueue.main.async {
                let coordinator = bubble.delayBubble?.coordinator
                if let cancellabble = coordinator?.cancellable, !cancellabble.isEmpty {
                    coordinator?.update(.user(.reset))
                }
                coordinator?.valueToDisplay = self.userEnteredStartDelay
            }
        }
    }
    
    func setColor(of bubble:Bubble, to newColor:String) {
        //don't do anything unless user changed color
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            guard let thisBubble = controller.grabObj(objID) as? Bubble else { return }
            
            thisBubble.color = newColor
            UserFeedback.singleHaptic(.medium)
            
            controller.save(bContext) {
                CalendarManager.shared.updateEvent(.title(thisBubble))
                
                let color = Color.bubbleColor(forName: thisBubble.color)
                DispatchQueue.main.async { //⚠️ main Thread
                    bubble.coordinator.color = color
                }
            }
        }
    }
    
    var durationPicker = DurationPicker()
    
    private var controller = PersistenceController.shared
    
    //both for Bubble- and PairStickyNoteList. cool, no? :)
    var stickyNoteText = ""
    var userChoseFromList = false
    
    // MARK: - BubbleCell
    func togglePin(_ bubble:Bubble) {
        
        let bContext = self.controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = self.controller.grabObj(objID) as? Bubble
            thisBubble?.isPinned.toggle()
            self.controller.save(bContext)
        }
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        guard CalendarManager.shared.calendarAccessStatus != .revoked else {
            secretary.showCalendarAccessDeniedWarning = true
            return
        }
        
        let objID = bubble.objectID
        let bContext = self.controller.bContext
                
        bContext.perform {
            guard let bBubble = bContext.object(with: objID) as? Bubble else { return }
                        
            bBubble.isCalendarEnabled.toggle()
            PersistenceController.shared.save(bContext) {
                self.calManager.shouldEventify(bBubble)
                print("1/5 toggle ", bBubble.sessions_.last?.pairs_.last)
            }
        }
    }
    
    func deleteName(of bubble:Bubble) {
        let objID = bubble.objectID
        let bContext = PersistenceController.shared.bContext
        
        //why the fuck that is??? ⚠️
        bubble.name = nil
        PersistenceController.shared.save()
        
        bContext.perform {
            let bBubble = self.controller.grabObj(objID) as! Bubble
            bBubble.name = nil
            CalendarManager.shared.updateEvent(.title(bBubble))
                        
            PersistenceController.shared.save(bContext)
        }
    }
}

extension ViewModel {
    enum Situation {
        case closeSession
        case start
        case pause
        case delete
        case reset
        case delay(Float)
    }
    
    ///before ct.state changed!!! timers only
    func setNotification(of timer:Bubble?, for situation:Situation) {
        guard let timer = timer, timer.isTimer else { return }
        
        switch situation {
            case .delay(let delay):
                guard timer.state == .paused || timer.state == .brandNew else { return }
                
                localNotificationsManager.scheduleNotification(for: timer, atSecondsFromNow: TimeInterval(timer.currentClock + delay), isSnooze: false)
                
            case .start:
                guard timer.state == .paused || timer.state == .brandNew else { return }
                
                localNotificationsManager.scheduleNotification(for: timer, atSecondsFromNow: TimeInterval(timer.currentClock), isSnooze: false)
                
            case .delete, .reset, .closeSession, .pause:
                if timer.state == .running {
                    localNotificationsManager.cancelScheduledNotification(for: timer)
                }
        }
    }
}

extension ViewModel {
    struct DurationPicker {
        // MARK: - DurationPicker
        
        var reason:Reason?
        
        enum Reason : Hashable, Identifiable {
            
            var id:String { UUID().uuidString }
            
            case createTimer(Color.Bicolor) //create timer in PaletteView
            case editExistingTimer(Bubble) //edit an existing timer
            case changeToTimer(Bubble) //change stopwatch to timer
            
            var description:String {
                switch self {
                    case .changeToTimer(let bubble):
                        return "reason change to \(bubble.color ?? "pula") timer"
                    case .createTimer(let bicolor):
                        return "reason create \(bicolor.description) timer"
                    case .editExistingTimer(let bubble):
                        return "reason edit existing timer \(bubble.color ?? "pula")"
                }
            }
        }
    }
}
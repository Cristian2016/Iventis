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
            HintOverlay.Model.shared.topmostView(oldValue.isEmpty ? .detail : .bubbleList)
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
        if initialNote == note.note { return }
        
        UserFeedback.singleHaptic(.light)
        
        let bContext = PersistenceController.shared.bContext
        let objID = pair.objectID
        let objID1 = note.objectID
        
        bContext.perform {
            let thisPair = PersistenceController.shared.grabObj(objID) as! Pair
            let thisPairNote = PersistenceController.shared.grabObj(objID1) as! PairSavedNote
            
            //set pair.note and show note
            thisPair.note = note.note
            thisPair.isNoteHidden = false
            
            thisPairNote.bubble = thisPair.session?.bubble
            note.date = Date()
            
            PersistenceController.shared.save(bContext)
            CalendarManager.shared.updateExistingEvent(.notes(thisPair.session!))
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
    
    //refresh widget when app resigns active
    private func observe_AppResignActive() {
        let name = UIApplication.willResignActiveNotification
        center.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in
            self?.refreshWidgets()
        }
    }
    
    // MARK: - Init
    init() {
        observe_AppResignActive()
        observe_KillSDB()
        observe_CreateTimer()
        observe_EditTimerDuration()
        observe_KillTimer()
        
        secretary.updateBubblesReport(.appLaunch)
    }
    
    let localNotificationsManager = ScheduledNotificationsManager.shared
    let calManager = CalendarManager.shared
    
    let delay:DispatchTime = .now() + 0.01
    
    ///PersistanceController.shared
    deinit { center.removeObserver(self) } //1
    
    // MARK: - background Timers
    var bubbleTimer = BubbleTimer()
    
    var moreOptionsSheetBubble:Bubble? { didSet {
        if let bubble = moreOptionsSheetBubble {
            HintOverlay.Model.shared.topmostView(.moreOptions)
        } else {
            HintOverlay.Model.shared.topmostView(path.isEmpty ? .bubbleList : .detail)
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
        
        UserFeedback.doubleHaptic(.heavy)
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        userEnteredStartDelay = 0
        
        bContext.perform {
            //2
            
            guard
                let thisBubble = controller.grabObj(objID) as? Bubble,
                let startDelayBubble = thisBubble.startDelayBubble
            else { return }
            
            thisBubble.startDelayBubble = nil //sdb removed from memory
            bContext.delete(startDelayBubble) //sdb removed from database
            
            DispatchQueue.main.async {
                bubble.startDelayBubble?.coordinator.update(.user(.pause))
                bubble.startDelayBubble?.coordinator = nil
            }
            
            controller.save(bContext)
        }
    }
    
    func saveStartDelay(_ bubble:Bubble) {
        //it uses MoreOptions.bubble
        
        let initialStartDelay = bubble.startDelayBubble?.initialClock ?? 0
        
        //make sure 1.user entered start delay and 2. is different from existing start delay
        guard userEnteredStartDelay != 0 && userEnteredStartDelay != initialStartDelay
        else { return }
        
        UserFeedback.singleHaptic(.heavy)
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = controller.grabObj(objID) as! Bubble
            
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
            sdb.initialClock = self.userEnteredStartDelay
            sdb.currentClock = sdb.initialClock
            thisBubble.startDelayBubble = sdb
            
            controller.save(bContext)
            
            DispatchQueue.main.async {
                let coordinator = bubble.startDelayBubble?.coordinator
                if let cancellabble = coordinator?.cancellable, !cancellabble.isEmpty {
                    coordinator?.update(.user(.reset))
                }
                coordinator?.valueToDisplay = self.userEnteredStartDelay
            }
        }
    }
    
    func setColor(of bubble:Bubble, to newColor:String) {
        //don't do anything unless user changed color
        UserFeedback.singleHaptic(.medium)
        
        var controller = PersistenceController.shared
        
        DispatchQueue.global().async {
            let bContext = controller.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let thisBubble = controller.grabObj(objID) as! Bubble
                thisBubble.color = newColor
                
                self.secretary.updateBubblesReport(.colorChange(thisBubble))
                
                //save changes to CoreData using bContext and update UI
                controller.save(bContext) { //⚠️ background Thread
                    let color = Color.bubbleColor(forName: thisBubble.color)
                    DispatchQueue.main.async { //⚠️ main Thread
                        bubble.coordinator.color = color
                    }
                }
            }
        }
    }
    
    
    var durationPicker = DurationPicker()
    
    private var controller = PersistenceController.shared
    
    //both for Bubble- and PairStickyNoteList. cool, no? :)
    var stickyNoteText = ""
    var userChoseNoteInTheList = false
    
    // MARK: - BubbleCell
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
    
    func toggleCalendar(_ bubble:Bubble) {
        guard CalendarManager.shared.calendarAccessStatus != .revoked else {
            secretary.showCalendarAccessDeniedWarning = true
            return
        }
        
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
    
}

extension ViewModel {
    enum NotificationSituation {
        case endSession
        case start
        case pause
        case delete
        case reset
    }
    
    ///before ct.state changed!!! timers only
    func setTimerNotification(_ situation:NotificationSituation, for timer:Bubble) {
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

extension ViewModel {
    struct DurationPicker {
        // MARK: - DurationPicker
        
        var reason:Reason?
        
        enum Reason : Hashable, Identifiable {
            
            var id:String { UUID().uuidString }
            
            case createTimer(Color.Tricolor) //create timer in PaletteView
            case editExistingTimer(Bubble) //edit an existing timer
            case changeToTimer(Bubble) //change stopwatch to timer
            
            var description:String {
                switch self {
                    case .changeToTimer(let bubble):
                        return "reason change to \(bubble.color ?? "pula") timer"
                    case .createTimer(let tricolor):
                        return "reason create \(tricolor.description) timer"
                    case .editExistingTimer(let bubble):
                        return "reason edit existing timer \(bubble.color ?? "pula")"
                }
            }
        }
    }
}

//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import Foundation
import SwiftUI


class ViewModel: ObservableObject {
    init() {
        let request = Bubble.fetchRequest()
        let bubbles = try? PersistenceController.shared.viewContext.fetch(request)
        bubbles?.forEach { $0.observeAppLaunch(.start) }
    }
    private let timer = BackgroundTimer(DispatchQueue(label: "BackgroundTimer", attributes: .concurrent))
    
    func backgroundTimer(_ action:BackgroundTimer.Action) {
        switch action {
            case .start: timer.perform(.start)
            case .pause: timer.perform(.pause)
        }
    }
    
    // MARK: - User Intents
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
        newBubble.rank = Int64(UserDefaults.assignRank())
        
        try? backgroundContext.save()
    }
    
    func delete(_ bubble:Bubble) {
        let viewContext = PersistenceController.shared.viewContext
        
        let request = Bubble.fetchRequest()
        let count = try? viewContext.count(for: request)
        let condition = count! > 1
        if condition { viewContext.delete(bubble) } else { return }
        
        try? viewContext.save()
    }
    
    func reset(_ bubble:Bubble) {
        let viewContext = PersistenceController.shared.viewContext
        bubble.created = Date()
        bubble.currentClock = bubble.initialClock
        bubble.timeComponentsString = bubble.initialClock.timComponentsAsStrings
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
                bubble.lastSession.addToPairs(newPair)
                
            case .running: /* changes to .paused */
                let currentPair = bubble.lastPair
                currentPair?.pause = Date()
                
                //⚠️ closure runs on the main queue. whatever you want the user to see put in that closure otherwise it will fail to update!!!!
                currentPair?.computeDuration(.pause) {
                    //closure runs on main queue
                    currentPair?.duration = $0 //Float
                    currentPair?.durationAsStrings = $1 //Data
                    
                    bubble.lastSession.computeDuration()
                    
                    //compute and store currentClock
                    bubble.currentClock += currentPair!.duration
                    bubble.timeComponentsString = bubble.currentClock.timComponentsAsStrings
                }
                
            case .finished: return
        }
        
        try? PersistenceController.shared.viewContext.save()
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        bubble.hasCalendar.toggle()
        PersistenceController.shared.save()
    }
    
    func showMoreOptions(_ bubble:Bubble) {
        
    }
    
    // FIXME: ⚠️ not complete!
    func endSession(_ bubble:Bubble) {
        if bubble.state == .brandNew { return }
        bubble.currentClock = bubble.initialClock
        bubble.timeComponentsString = bubble.currentClock.timComponentsAsStrings
        bubble.lastSession.isEnded = true
        if bubble.lastPair!.pause == nil {
            bubble.lastPair!.pause = Date()
            bubble.lastPair?.computeDuration(.endSession) {
                bubble.lastPair?.duration = $0
                bubble.lastPair?.durationAsStrings = $1
                
                bubble.lastSession.computeDuration()
                
                bubble.timeComponentsString = bubble.initialClock.timComponentsAsStrings
            }
        }
        
        try? PersistenceController.shared.viewContext.save()
    }
}

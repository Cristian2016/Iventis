//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import Foundation
import SwiftUI


class ViewModel: ObservableObject {
    private let timer = BackgroundTimer(DispatchQueue(label: "BackgroundTimer", attributes: .concurrent))
    
    func timer(_ action:BackgroundTimer.Action) {
        switch action {
            case .start: timer.perform(.start)
            case .pause: timer.perform(.pause)
        }
    }
    
    // MARK: -
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
        viewContext.delete(bubble)
        try? viewContext.save()
    }
    
    func reset(_ bubble:Bubble) {
        let backgroundContext = PersistenceController.shared.backgroundContext
        bubble.created = Date()
        bubble.currentClock = bubble.initialClock
        try? backgroundContext.save()
    }
    
    // MARK: - Testing Only
    func makeBubbles() {
        PersistenceController.shared.backgroundContext.perform {
            for _ in 0..<3 {
                let newBubble = Bubble(context: PersistenceController.shared.backgroundContext)
                newBubble.created = Date()
                newBubble.currentClock = 0
            }
            
            try? PersistenceController.shared.backgroundContext.save()
        }
    }
    
    // MARK: -
    func toggle(_ bubble:Bubble) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  { return }
        
        switch bubble.state {
            case .brandNew: /* changes to .running */
                //create first session and add first pair to the session
                let firstSession = Session(context: PersistenceController.shared.viewContext)
                let firstPair = Pair(context: PersistenceController.shared.viewContext)
                firstPair.start = Date()
                bubble.addToSessions(firstSession)
                firstSession.addToPairs(firstPair)
                                
            case .paused:  /* changes to running */
                //create new pair, add it to currentSession
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date()
                bubble.currentSession.addToPairs(newPair)
                
            case .running: /* changes to .paused */
                let latestPair = bubble.currentPair
                latestPair?.pause = Date()
                //compute duration
                latestPair!.duration = Float(latestPair!.pause!.timeIntervalSince(latestPair!.start))
                
                //compute and store currentClock
                bubble.currentClock += latestPair!.duration
                try? PersistenceController.shared.viewContext.save()
                
            case .finished: return
        }
        
        try? PersistenceController.shared.viewContext.save()
//        print(bubble.state, "bubble state")
    }
}

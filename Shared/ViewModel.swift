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
        newBubble.state_ = .brandNew
        
        newBubble.kind = kind
        switch kind {
            case .timer(referenceClock: let referenceClock):
                newBubble.initialClock = referenceClock
            default: newBubble.initialClock = 0
        }
        
        newBubble.color = color
        newBubble.rank
        newBubble
        
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
                newBubble.state_ = .brandNew
            }
            
            try? PersistenceController.shared.backgroundContext.save()
        }
    }
    
    // MARK: -
    func toggle(_ bubble:Bubble) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  { return }
        
        switch bubble.state_ {
            case .brandNew:
                bubble.state_ = .running
            case .paused:
                bubble.state_ = .running
            case .running:
                bubble.state_ = .paused
                try? PersistenceController.shared.viewContext.save()
            case .finished: return
        }
    }
}

//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import Foundation


class ViewModel: ObservableObject {
    private let timer = BackgroundTimer(DispatchQueue(label: "BackgroundTimer", attributes: .concurrent))
    
    func timer(_ action:BackgroundTimer.Action) {
        switch action {
            case .start: timer.perform(.start)
            case .pause: timer.perform(.pause)
        }
    }
    
    init() {
        let request = Bubble.fetchRequest()
        if let bubbles = try? PersistenceController.shared.container.viewContext.fetch(request) {
            bubbles.forEach { $0.observeBackgroundTimer(.start)
            }
        }
    }
    
    // MARK: -
    func createBubble(_ kind:Bubble.Kind) {
        let backgroundContext = PersistenceController.shared.backgroundContext
        let newBubble = Bubble(context: backgroundContext)
        newBubble.created = Date()
        newBubble.state_ = .brandNew
        
        newBubble.kind = kind
        switch kind {
            case .timer(referenceClock: let referenceClock):
                newBubble.initialClock = referenceClock
            default:
                newBubble.initialClock = 0
        }
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
}

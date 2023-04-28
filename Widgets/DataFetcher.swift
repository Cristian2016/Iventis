//
//  DataFetcher.swift
//  WidgetsExtension
//
//  Created by Cristian Lapusan on 28.04.2023.
//

import Foundation
import CoreData

struct DataFetcher {
    func fetch(completion: @escaping (Bool, Float) -> Void) {
        let bContext = PersistenceController.shared.bContext
        bContext.perform {
            guard let bubbleRank = try? String(contentsOf: URL.objectIDFileURL) else { return }
            let rank = Int64(bubbleRank)!
            
            let request = Bubble.fetchRequest()
            request.predicate = NSPredicate(format: "rank = %i", rank)
            guard let bubble = try? bContext.fetch(request).first else { fatalError() }
            
            let isRunning = bubble.state == .running
            
            if isRunning {
                guard let lastStart = bubble.lastPair?.start else { return }
                let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart))
                let value = bubble.isTimer ? bubble.currentClock - elapsedSinceLastStart : bubble.currentClock + elapsedSinceLastStart
                
                completion(isRunning, value)
            } else {
                completion(isRunning, bubble.currentClock)
            }
        }
    }
}

//
//  DataFetcher.swift
//  WidgetsExtension
//
//  Created by Cristian Lapusan on 28.04.2023.
//

import Foundation
import CoreData

struct DataFetcher {
    struct BubbleData {
        let value:Float
        let isTimer:Bool
        let isRunning:Bool
    }
    
    func fetch(completion: @escaping (BubbleData?) -> Void) {
        let bContext = PersistenceController.shared.bContext
        bContext.perform {
            guard let bubbleRank = try? String(contentsOf: URL.objectIDFileURL) else { return }
            guard let rank = Int64(bubbleRank) else {
                completion(nil)
                return
            }
            
            let request = Bubble.fetchRequest()
            request.predicate = NSPredicate(format: "rank = %i", rank)
            guard let bubble = try? bContext.fetch(request).first else { fatalError() }
            
            let isRunning = bubble.state == .running
            
            if isRunning {
                guard let lastStart = bubble.lastPair?.start else { return }
                
                let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart))
                
                let value = bubble.isTimer ? bubble.currentClock - elapsedSinceLastStart : bubble.currentClock + elapsedSinceLastStart
                
                let bubbleData = BubbleData(value: value,
                                            isTimer: bubble.isTimer,
                                            isRunning: isRunning)
                
                completion(bubbleData)
            } else {
                
                let bubbleData = BubbleData(value: bubble.currentClock,
                                            isTimer: bubble.isTimer,
                                            isRunning: isRunning)
                completion(bubbleData)
            }
        }
    }
}

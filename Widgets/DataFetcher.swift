//
//  DataFetcher.swift
//  WidgetsExtension
//
//  Created by Cristian Lapusan on 28.04.2023.
//

import Foundation
import CoreData

struct DataFetcher {
    func fetch() {
        let bContext = PersistenceController.shared.bContext
        bContext.perform {
            guard let bubbleRank = try? String(contentsOf: URL.objectIDFileURL) else { return }
            let rank = Int64(bubbleRank)!
            
            let request = Bubble.fetchRequest()
            request.predicate = NSPredicate(format: "rank = %i", rank)
            guard let bubbles = try? bContext.fetch(request) else { fatalError() }
            print("recently used is ? \(bubbles.first!.color)")
        }
    }
}

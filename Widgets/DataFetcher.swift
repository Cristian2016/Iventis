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
            let request = Bubble.fetchRequest()
            guard let bubbles = try? bContext.fetch(request) else { fatalError() }
            
            let colors = bubbles.compactMap { $0.color }
            print("widget has fetched colors \(colors)")
        }
    }
}

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
            guard let objID = try? String(contentsOf: URL.objectIDFileURL) else { return }
            print("got object ID \(objID)")
            
            let request = Bubble.fetchRequest()
//            request.predicate = NSPredicate(format: <#T##String#>, <#T##args: CVarArg...##CVarArg#>)
            guard let bubbles = try? bContext.fetch(request) else { fatalError() }
            
            let colors = bubbles.compactMap { $0.color }
            print("widget has fetched colors \(colors)")
        }
    }
}

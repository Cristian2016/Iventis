//
//  DataFetcher.swift
//  WidgetsExtension
//
//  Created by Cristian Lapusan on 28.04.2023.
//

import Foundation
import CoreData

struct DataFetcher {
    func fetch(completion: @escaping (BubbleData?) -> Void) {
        guard
            let data = UserDefaults.shared.value(forKey: "bubbleData") as? Data,
            let bubbleData = try? JSONDecoder().decode(BubbleData.self, from: data)
        else { return }
                        
        completion(bubbleData)
    }
}

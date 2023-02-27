//
//  Session+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 23.04.2022.
//
//

import Foundation
import CoreData


public class Session: NSManagedObject {
    deinit {
//        print("session deinit")
    }
    
    //⚠️ implement on backgroundthread. warning: wait until pair computes its duration and then compute session.totalduration!!!
    func computeDuration(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            
            let pairs = self.pairs_
            
            guard !pairs.isEmpty,
                  let lastPairDuration = pairs.last?.duration else { fatalError() }
            
            self.totalDuration += lastPairDuration
            
            let encoder = JSONEncoder()
            let data = try? encoder.encode(self.totalDuration.timeComponentsAsStrings)
            self.totalDurationAsStrings = data
            
            DispatchQueue.main.async { completion() }
        }
    }
    
    var isLastPairClosed:Bool { bubble?.lastPair?.pause != nil }
    
    var pairs_:[Pair] {
        pairs?.array as? [Pair] ?? []
    }
}

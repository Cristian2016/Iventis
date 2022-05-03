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
    
    //⚠️ implement on backgroundthread. warning: wait until pair computes its duration and then compite session.totalduration!!!
    func computeSessionDuration() {
        DispatchQueue.global().async {
            let pairs = self.pairs?.array as! [Pair]
            guard !pairs.isEmpty,
                  let lastPairDuration = pairs.last?.duration else { fatalError() }
            
            DispatchQueue.main.async {
                self.totalDuration += lastPairDuration
                PersistenceController.shared.save()
            }
        }
    }
    
    var pairs_:[Pair] {
        get { pairs?.array as? [Pair] ?? [] }
        set {
            pairs = NSOrderedSet(array: newValue)
            print("update pairs")
        }
    }
}

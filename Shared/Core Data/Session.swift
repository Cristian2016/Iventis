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
    func computeTotalDuration() {
        let pairs = pairs.array as! [Pair]
        guard !pairs.isEmpty,
        let lastPairDuration = pairs.last?.duration else { fatalError() }
        
        totalDuration += lastPairDuration
//        print("session duration \(totalDuration)")
        
        //⚠️ no need to save context!
    }
}

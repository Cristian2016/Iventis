//
//  Session+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 23.04.2022.
//
//

import Foundation
import CoreData
import MyPackage


public class Session: NSManagedObject {
    deinit {
//        print("session deinit")
    }
    
    //⚠️ will run on a backgroundthread. wait until pair computes its duration and then compute session.totalduration!
    func computeDuration() {
        let pairs = self.pairs_
        guard !pairs.isEmpty,
              let lastPairDuration = pairs.last?.duration else { return }
        
        totalDuration += lastPairDuration
        
        lastTrackerDuration += lastPairDuration
    }
    
    private func resetLastTrackerDuration()  { lastTrackerDuration = 0 }
    
    var isLastPairClosed:Bool { bubble?.lastPair?.pause != nil }
    
    var isMostRecent:Bool {
        return bubble?.sessions_.last == self
    }
    
    var pairs_:[Pair] {
        pairs?.array as? [Pair] ?? []
    }
    
    func handleTrackerID(_ action:TrackerIDAction) {
        switch action {
            case .assign(let pair):
                pair.trackerID = trackerIDCounter
            case .increment:
                resetLastTrackerDuration()
                trackerIDCounter += 1
        }
    }
    
    enum TrackerIDAction {
        case increment
        case assign(Pair)
    }
}

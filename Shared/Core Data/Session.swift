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
              let lastPairDuration = pairs.last?.duration else { fatalError() }
        totalDuration += lastPairDuration
        
        lastTrackerDuration += lastPairDuration
        print("lastTrackerDuration \(lastTrackerDuration)")
    }
    
    private func resetLastTrackerDuration()  {
        print(#function)
        lastTrackerDuration = 0
    }
    
    var isLastPairClosed:Bool { bubble?.lastPair?.pause != nil }
    
    var pairs_:[Pair] {
        pairs?.array as? [Pair] ?? []
    }
    
    func handleTrackerID(_ action:TrackerIDAction) {
        switch action {
            case .assign(let pair):
                pair.trackerID = trackerIDCounter
                print("pair trackerIDCounter \(pair.trackerID)")
            case .increment:
                resetLastTrackerDuration()
                trackerIDCounter += 1
                print("trackerIDCounter \(trackerIDCounter)")
        }
    }
    
    enum TrackerIDAction {
        case increment
        case assign(Pair)
    }
}

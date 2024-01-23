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
    //⚠️ will run on a backgroundthread. wait until pair computes its duration and then compute session.totalduration!
    func computeDuration() {
        let pairs = self.pairs_
        guard !pairs.isEmpty,
              let lastPairDuration = pairs.last?.duration else { return }
        
        totalDuration += lastPairDuration
        
        lastBubbleDuration += lastPairDuration
    }
    
    private func resetLastBubbleDuration()  { lastBubbleDuration = 0 }
    
    var isLastPairClosed:Bool { bubble?.lastPair?.pause != nil }
    
    var isMostRecent:Bool {
        return bubble?.sessions_.last == self
    }
    
    var pairs_:[Pair] {
        pairs?.array as? [Pair] ?? []
    }
    
    var lastPair:Pair? {
        pairs_.last
    }
    
    func handleBubbleID(_ action:BubbleIDAction) {
        switch action {
            case .assign(let pair):
                pair.bubbleID = bubbleIDCounter
            case .increment:
                resetLastBubbleDuration()
                bubbleIDCounter += 1
        }
    }
    
    enum BubbleIDAction {
        case increment
        case assign(Pair)
    }
    
    var hasFinalEvent:Bool { eventID != nil }
    var hasAnyEvent:Bool { eventID != nil || temporaryEventID != nil }
}

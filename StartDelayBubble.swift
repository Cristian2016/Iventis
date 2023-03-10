//
//  StartDelayBubble+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//

import Foundation
import CoreData


public class StartDelayBubble: NSManagedObject {
    enum State {
        case brandNew
        case running
        case paused
    }
    
    var state: State {
        if pairs_.isEmpty { return .brandNew }
        else {
            let lastPair = pairs_.last!
            return lastPair.pause != nil ? .paused : .running
        }
    }
    
    var pairs_:[SDBPair] {
        get { pairs?.array as? [SDBPair] ?? [] }
        set { pairs = NSOrderedSet(array: newValue) }
    }
}

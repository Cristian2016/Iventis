//
//  DSB+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//
//

import Foundation
import CoreData

///StartDelay_Bubble
public class SDB: NSManagedObject {
    var backgroundTimer:SDBTimer?
    lazy var dispatchQueue = DispatchQueue(label: "sdbTimer")
    
    enum State {
        case brandNew
        case running
        case paused
    }
    
    var state = State.brandNew
    
    // MARK: - User Intents
    func toggleStart() {
        print(#function, state)
        switch state {
            case .brandNew, .paused:
                state = .running
                if backgroundTimer == nil {
                    backgroundTimer = SDBTimer(dispatchQueue, rank: bubble?.rank)
                }
                backgroundTimer?.perform(.start)
            case .running:
                state = .paused
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
        }
    }
    
    
    deinit {
        print("deinit")
    }
}

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
    
    // MARK: -
    func observeSDBTimer() {
        NotificationCenter.default.addObserver(forName: .sdbTimerSignal, object: nil, queue: nil) { [weak self] _ in
            
            guard let self = self else { return }
            guard self.state == .running else { return }
            
            if self.delay > 0 { self.delay -= 1 }
            else {
                print("set to brandnew again")
                self.backgroundTimer?.perform(.pause)
                self.backgroundTimer = nil
                self.state = .brandNew
            }
        }
    }
    
    deinit {
        print("deinit")
    }
}

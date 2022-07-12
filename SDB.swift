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
        case finished
    }
    
    var state = State.brandNew
    
    // MARK: - User Intents
    func toggleStart() {
        switch state {
            case .brandNew, .paused:
                state = .running
                if backgroundTimer == nil {
                    backgroundTimer = SDBTimer(dispatchQueue)
                }
                backgroundTimer?.perform(.start)
                print("start")
            case .running:
                state = .paused
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
            case .finished:
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
        }
    }
    
    // MARK: -
    func observeSDBTimer() {
        NotificationCenter.default.addObserver(forName: .sdbTimerSignal, object: nil, queue: nil) { [weak self] notification in
            
            guard let self = self else { return }
            print("notification received for \(self.bubble!.color!)")
            
            if self.delay > 0 {
                self.delay -= 1
                print(self.delay)
            }
            else {
                self.backgroundTimer?.perform(.pause)
                self.backgroundTimer = nil
            }
        }
    }
    
    deinit {
        print("deinit")
    }
}

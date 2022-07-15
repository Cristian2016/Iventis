//
//  DSB+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//
//

import Foundation
import CoreData
import SwiftUI

///StartDelay_Bubble
public class SDB: NSManagedObject {
    var backgroundTimer:SDBTimer?
    
    enum State {
        case brandNew
        case running
        case paused
    }
    
    var state = State.brandNew
    
    // MARK: - User Intents
    func toggleStart() {
        switch state {
            case .brandNew, .paused:
                if backgroundTimer == nil {
                    backgroundTimer = SDBTimer { [weak self] in
                        self?.task()
                    }
                }
                state = .running
                
                //without delay sdb.delay will be descreased instantly
                delayExecution(.now() + 1) {
                    self.backgroundTimer?.perform(.start)
                }
                
            case .running:
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
                state = .paused
        }
    }
    
    //task to call each second by bTimer
    func task() {
        guard currentDelay > 0 else { return }
        
        if currentDelay == 1 {
            backgroundTimer?.perform(.pause)
            backgroundTimer = nil
            state = .brandNew
            
            //notification to ViewModel to start bubble automatically
            //viewModel receives notification and
            //calls vm.toggleStart(bubble!)
            //vm.sdb = nil causes SDBCell to go away
            NotificationCenter.default.post(name: .sdbDelayreachedZero, object: self)
        }
        
        DispatchQueue.main.async { self.objectWillChange.send() }
        currentDelay -= 1 //decrease by one
    }
}

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
    
    enum State:String {
        case brandNew
        case running
        case paused
    }
    
    var state = State.brandNew
    
    // MARK: - User Intents
    func resetDelay() {
        //stop bTimer
        backgroundTimer?.perform(.pause)
        backgroundTimer = nil
        
        //⚠️ why delay?
        //if no delay set, reset goes wrong!
        delayExecution(.now() + 0.01) {
            self.currentDelay = self.referenceDelay
            self.state = .brandNew
            PersistenceController.shared.save()
        }
        
    }
    
    func removeDelay() {
        //remove bTimer
        //set both delays to zero
        //save CoreData
        
        if backgroundTimer != nil {
            backgroundTimer?.perform(.pause)
            backgroundTimer = nil
        }
        
        referenceDelay = 0
        currentDelay = 0
        
        PersistenceController.shared.save()
    }
    
    func toggleStart() {
        print(#function)
        switch state {
            case .brandNew, .paused:
                if backgroundTimer == nil {
                    backgroundTimer = SDBTimer { [weak self] in
                        self?.bTimerTask()
                    }
                }
                state = .running
                
                //without delay sdb.delay will be increased instantly
                delayExecution(.now() + 1) {
                    self.backgroundTimer?.perform(.start)
                }
                
            case .running:
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
                state = .paused
        }
        
        PersistenceController.shared.save()
    }
    
    
    ///easy to handle entering background or becoming active
    func start(_ isStart:Bool) {
        switch isStart {
            case true: //start
                if backgroundTimer == nil {
                    backgroundTimer = SDBTimer { [weak self] in
                        self?.bTimerTask()
                    }
                }
                state = .running
                
                //without delay sdb.delay will be increased instantly
                delayExecution(.now() + 1) {
                    self.backgroundTimer?.perform(.start)
                }
            case false: //pause
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
                state = .paused
        }
    }
    
    //task to call each second by bTimer
    func bTimerTask() {
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

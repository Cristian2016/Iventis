//
//  SDB+CoreDataClass.swift
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
    enum State:String {
        case brandNew
        case running
        case paused
    }
    
    var state = State.brandNew
    
    // MARK: - User Intents
    func toggleStart() {
        switch state {
            case .brandNew, .paused:
                state = .running
                observeSDBTimer()
                
            case .running:
                state = .paused
                print("remove observer")
                NotificationCenter.default.removeObserver(self)
        }
        
        PersistenceController.shared.save()
    }
    
    func resetDelay() {
        //stop bTimer
        
        //⚠️ why delay?
        //if no delay set, reset goes wrong!
        delayExecution(.now() + 0.01) {
            self.currentDelay = Float(self.referenceDelay)
            self.state = .brandNew
            NotificationCenter.default.removeObserver(self)
            PersistenceController.shared.save()
        }
        
    }
    
    func removeDelay() {
        //remove bTimer
        //set both delays to zero
        //save CoreData
        
       //was timer shit here
        
        referenceDelay = 0
        currentDelay = 0
        
        PersistenceController.shared.save()
    }
    
    
    ///easy to handle entering background or becoming active
    func start(_ isStart:Bool) {
        switch isStart {
            case true: //start
                state = .running
                
            case false: //pause
                
                state = .paused
        }
    }
    
    //task to call each second by bTimer
    func bTimerTask() {
        guard currentDelay > 0 else { return }
        
        if currentDelay == 1 {
            state = .brandNew
            
            //notification to ViewModel to start bubble automatically
            //viewModel receives notification and
            //calls vm.toggleStart(bubble!)
            //vm.sdb = nil causes SDBCell to go away
            NotificationCenter.default.post(name: .sdbDelayreachedZero, object: self)
        }
        
        currentDelay -= 1 //decrease by one
    }
    
    func observeSDBTimer() {
        NotificationCenter.default
            .addObserver(forName: .sdbTimerSignal, object: nil, queue: nil) {
                [weak self] _ in
                print("sdbTimerSignal received")
            }
    }
    
    func handleNotification() {
        guard currentDelay > 0 else {
            state = .paused
            return
        }
        
        if state == .running {
            if currentDelay == 0 {
                referenceDelay = Int64(currentDelay)
            }
            currentDelay -= 1
        }
    }
}

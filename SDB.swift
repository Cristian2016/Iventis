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
    func resetDelay() {
        //stop bTimer
        
        //⚠️ why delay?
        //if no delay set, reset goes wrong!
        delayExecution(.now() + 0.01) {
            self.currentDelay = Int64(self.referenceDelay_)
            self.state = .brandNew
            PersistenceController.shared.save()
        }
        
    }
    
    func removeDelay() {
        //remove bTimer
        //set both delays to zero
        //save CoreData
        
       //was timer shit here
        
        referenceDelay_ = 0
        currentDelay = 0
        
        PersistenceController.shared.save()
    }
    
    func toggleStart() {
        switch state {
            case .brandNew, .paused:
                state = .running
                
            case .running:
                state = .paused
        }
        
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
        
        DispatchQueue.main.async { self.objectWillChange.send() }
        currentDelay -= 1 //decrease by one
    }
    
    func observeSDBTimer() {
        NotificationCenter.default
            .addObserver(forName: .sdbTimerSignal, object: nil, queue: nil) {
                [weak self] _ in
               print("sdbTimerSignal received")
            }
    }
    
    private var isObservingSDBTimer = false
    
    var referenceDelay_:Int {
        get { Int(referenceDelay) }
        set {
            referenceDelay = Int64(newValue)
            
            let shouldObserveTimer = newValue > 0
            
            if shouldObserveTimer {
                if !isObservingSDBTimer {
                    observeSDBTimer()
                    isObservingSDBTimer = true
                    print("add observer \(referenceDelay_)")
                }
            }
            else {
                if isObservingSDBTimer {
                    NotificationCenter.default.removeObserver(self)
                    isObservingSDBTimer = false
                    print("remove observer \(referenceDelay_)")
                }
            }
        }
    }    
}

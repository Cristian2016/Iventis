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
    lazy var center = NotificationCenter.default
    
    enum State:String {
        case brandNew
        case running
        case paused
    }
    
    var state = State.brandNew
    
    var observe = false
    var isObserverAdded = false
    
    // MARK: - User Intents
    func toggleStart() {
        switch state {
            case .brandNew, .paused:
                state = .running
                
                if !isObserverAdded {
                    observeSDBTimer()
                    isObserverAdded = true
                }
                
                observe = true
                
            case .running:
                state = .paused
                observe = false
        }
        
        PersistenceController.shared.save()
    }
    
    func resetDelay() {
        
        observe = false
        
        //⚠️ why delay?
        //if no delay set, reset goes wrong!
        delayExecution(.now() + 0.01) {
            self.currentDelay = Float(self.referenceDelay)
            self.state = .brandNew
            self.observe = false
            PersistenceController.shared.save()
        }
    }
    
    ///delay removed either by removing SDButton from Bubble Cell
    ///or longPress in MoreOptionsView
    func removeDelay() {
        //set both delays to zero
        //save CoreData
                
        referenceDelay = 0
        currentDelay = 0
        observe  /* notifications */ = false
        
        PersistenceController.shared.save()
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
        center.addObserver(forName: .sdbTimer, object: nil, queue: nil) { [weak self] _ in
            DispatchQueue.main.async { self?.handleNotification() }
        }
    }
    
    func handleNotification() {
        guard observe /* notifications */ else { return }
        
        print(#function)
        guard currentDelay > 0 else {
            state = .paused
            removeDelay()
            return
        }
        
        if state == .running {
            if currentDelay == 0 {
                referenceDelay = Int64(currentDelay)
            }
            currentDelay -= 1
        }
    }
    
    deinit { center.removeObserver(self) }
}

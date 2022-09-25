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
    
    private var observerAddedAlready = false
    
    enum State:String {
        case brandNew
        case running
        case paused
    }
    
    var state = State.brandNew
        
    // MARK: - User Intents
    func toggleStart() {
        switch state {
            case .brandNew, .paused: //🔴 start
                state = .running //start handle observe timer
                
                //create newPair and set newPair.start date
                let newSDBPair = SDBPair(context: managedObjectContext!)
                newSDBPair.start = Date()
                addToPairs(newSDBPair)
                addObserver()
                
            case .running: //🔴 pause
                state = .paused //stop handle observe timer
                
                //set pause and compute duration
                lastPair?.pause = Date()
                let duration = lastPair!.pause!.timeIntervalSince(lastPair!.start!)
        }
        
        PersistenceController.shared.save()
    }
    
    func resetDelay() {
        //⚠️ why delay?
        //if no delay set, reset goes wrong!
        delayExecution(.now() + 0.01) {
            self.currentDelay = Float(self.referenceDelay)
            self.state = .brandNew
            PersistenceController.shared.save()
        }
    }
    
    ///delay removed either by removing SDButton from Bubble Cell
    ///or longPress in MoreOptionsView
    func removeDelay() {
        referenceDelay = 0
        currentDelay = 0
        state = .brandNew
        
        PersistenceController.shared.save()
    }
    
    //task to call each second by bTimer
    func timerTask() {
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
    
    func addObserver() {
        //make sure observer added only once
        if observerAddedAlready { return }
        observerAddedAlready = true
        
        NotificationCenter.default.addObserver(forName: .bubbleTimerSignal, object: nil, queue: nil) { [weak self] _ in
            delayExecution(.now() + 1) { self?.handleNotification() }
        }
    }
    
    func handleNotification() {
        guard state == .running /* notifications */ else { return }
        print(#function)
        
        DispatchQueue.main.async {
            if let start = self.lastPair?.start {
               let elapsed = Date().timeIntervalSince(start)
                self.currentDelay -= Float(elapsed)
            }
            
            if self.currentDelay == 0 { self.removeDelay() }
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

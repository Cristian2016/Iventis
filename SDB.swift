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
            case .brandNew, .paused: //start SDB
                state = .running //start handle observe timer
                
                //create newPair and set newPair.start date
                let newSDBPair = SDBPair(context: managedObjectContext!)
                newSDBPair.start = Date()
                addToPairs(newSDBPair)
                addObserver()
                
            case .running: //pause SDB
                state = .paused //stop handle observe timer
                
                //set pause and compute duration
                lastPair?.pause = Date()
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
        //resets both reference and current delays back to zero
        //resets state back to .brandNew
        //removes all pairs
        //saves context
        
        referenceDelay = 0
        currentDelay = 0
        state = .brandNew
        removeFromPairs(at: NSIndexSet(indexSet: IndexSet(pairs_.indices)))
        
        PersistenceController.shared.save()
    }
    
    func addObserver() {
        //make sure observer added only once
        if observerAddedAlready { return }
        observerAddedAlready = true
        
        NotificationCenter.default.addObserver(forName: .bubbleTimerSignal, object: nil, queue: nil) { [weak self] _ in self?.updateCurrentDelay() }
    }
    
    func updateCurrentDelay() {
        //make sure it updates only if SDB is running
        guard
            state == .running,
            let lastStartDate = lastPair?.start
        else { return }
                
        let delta = Date().timeIntervalSince(lastStartDate)
        
        DispatchQueue.main.async {
            if delta < 1 { self.currentDelay -= Float(delta) }
            else { self.currentDelay -= 1 }
        }
        
        if self.currentDelay <= 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .sdbEnded, object: self)
                self.removeDelay()
            }
        }
    }
    
    // MARK: -
    deinit { NotificationCenter.default.removeObserver(self) }
}

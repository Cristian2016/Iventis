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
                state = .running
                if backgroundTimer == nil {
                    backgroundTimer = SDBTimer { [weak self] in
                        self?.task()
                    }
                }
                
                //without delay sdb.delay will be descreased instantly
                delayExecution(.now() + 1) {
                    self.backgroundTimer?.perform(.start)
                }
                
            case .running:
                state = .paused
                backgroundTimer?.perform(.pause)
                backgroundTimer = nil
        }
    }
    
    //task to call each second by bTimer
    func task() {
        guard delay > 0 else { return }
        
        if delay == 1 {
            backgroundTimer?.perform(.pause)
            backgroundTimer = nil
//            vm.sdb = nil
            state = .brandNew
            
            //start bubble automatically
//            vm.toggleStart(bubble!)
        }
        
        DispatchQueue.main.async { self.objectWillChange.send() }
        delay -= 1 //decrease by one
    }
    
    deinit {
        print("deinit")
    }
}

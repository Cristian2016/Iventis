//
//  Bubble+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//
//

import Foundation
import CoreData
import SwiftUI

public class Bubble: NSManagedObject {
    enum State {
        case brandNew //0
        case running //1
        case paused //2
        case finished //3 timers only
    }
    
    var state_:State {
        get {
            switch state {
                case 0: return .brandNew
                case 1: return .running
                case 2: return .paused
                case 3: return .finished ///timers only
                                         ///
                default: return .brandNew
            }
        }
        
        set {
            switch newValue {
                case .brandNew: state = 0
                case .running: state = 1
                case .paused: state = 2
                case .finished: state = 3 //timers only
            }
        }
    }
    
    // MARK: - Observing BackgroundTimer
    ///receivedValue is NOT saved to database
    @Published var fakeClock = Float(0) { willSet { self.objectWillChange.send() }}
    @Published var components = (hr:0, min:0, sec:0) { willSet { self.objectWillChange.send() }}
    
    deinit { observeBackgroundTimer(.stop) }
    
    enum Kind:Comparable {
        case stopwatch
        case timer(referenceClock:Float)
    }
    
    var kind:Kind {
        get {
            switch initialClock {
                case 0: return .stopwatch
                default: return .timer(referenceClock: initialClock)
            }
        }
        
        set {
            switch newValue {
                case .stopwatch: self.initialClock = 0
                case .timer(referenceClock: let initialClock): self.initialClock = initialClock
            }
        }
    }
}

// MARK: - Observing BackgroundTimer
extension Bubble {
    enum Observe {
        case start
        case stop
    }
    
    ///update receivedValue only if bubble is running
    func observeBackgroundTimer(_ observe:Observe) {
        switch observe {
            case .start:
                NotificationCenter.default.addObserver(forName: .valueUpdated, object: nil, queue: nil) { [weak self] notification in
                    guard let self = self, self.state_ == .running else { return }
                    
                    //since closure is executed on background thread, dispatch back to the main thread
                    DispatchQueue.main.async {
                        self.components = self.fakeClock.timeComponents()
                        self.fakeClock += self.currentClock + 1
                    }
                }
            default: NotificationCenter.default.removeObserver(self)
        }
    }
}

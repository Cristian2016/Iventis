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
    
    var state:State {
        if kind != .stopwatch && currentClock <= 0 {
            return .finished
        } else {
            if sessions_.isEmpty { return .brandNew }
            else {
                if latestPair!.pause == nil { return .running }
                else { return .paused }
            }
        }
    }
    
    var sessions_:[Session] {
        sessions?.array as? [Session] ?? []
    }
    var latestSession:Session { sessions_.last! }
    
    var latestPair:Pair? { (latestSession.pairs.array as? [Pair])?.last }
    
    // MARK: - Observing BackgroundTimer
    ///receivedValue is NOT saved to database
    @Published var fakeClock = Float(0) { willSet { self.objectWillChange.send() }}
    @Published var components = (hr:0, min:0, sec:0) { willSet { self.objectWillChange.send() }}
    private(set) var isObservingBackgroundTimer = false
    
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
        isObservingBackgroundTimer = true
        
        switch observe {
            case .start:
                NotificationCenter.default.addObserver(forName: .valueUpdated, object: nil, queue: nil) { [weak self] notification in
                    guard let self = self, self.state == .running else { return }
                    
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

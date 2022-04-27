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
        if kind != .stopwatch && currentClock <= 0 { return .finished }
        else {
            if sessions_.isEmpty { return .brandNew }
            else {
                if currentPair!.pause == nil { return .running }
                else { return .paused }
            }
        }
    }
    
    var sessions_:[Session] {
        sessions?.array as? [Session] ?? []
    }
    
    var currentSession:Session { sessions_.last! }
    
    var currentPair:Pair? { (currentSession.pairs.array as? [Pair])?.last }
    
    // MARK: -
    ///bubbleCell.body displays timeComponents
    @Published var timeComponents = (hr:0, min:0, sec:0) { willSet {
        self.objectWillChange.send()
    }}
    
    private(set) var isObservingBackgroundTimer = false
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    enum Kind:Comparable {
        case stopwatch
        case timer(_ initialClock:Float)
    }
    
    var kind:Kind {
        get {
            switch initialClock {
                case 0: return .stopwatch
                default: return .timer(initialClock)
            }
        }
        
        set {
            switch newValue {
                case .stopwatch: self.initialClock = 0
                case .timer(let initialClock): self.initialClock = initialClock
            }
        }
    }
}

// MARK: - Observers
extension Bubble {
    enum ObserveState {
        case start
        case stop
    }
    
    ///observe backgroundtimer signal. update time components only if bubble is running
    func observeBackgroundTimer() { isObservingBackgroundTimer = true
        
        NotificationCenter.default.addObserver(forName: .backgroundTimerSignalReceived, object: nil, queue: nil) {
            
            [weak self] _ in
            self?.updateTimeComponents()
        }
    }
    
    ///set bubble.timeComponents. called [once] on app launch
    func observeAppLaunch(_ observe:ObserveState) {
        switch observe {
            case .start:
                NotificationCenter.default.addObserver(forName: .appLaunched, object: nil, queue: nil) { [weak self] notification in
                    guard let self = self else { return }
                                        
                    //time to set timeComponents to an initial value. forget about (hr:0, min:0, sec:0)
                    let components = self.currentClock.timeComponents()
                    DispatchQueue.main.async { self.timeComponents = components }
                }
            default: NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func updateTimeComponents() {
        if state != .running { return }
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(currentPair!.start)
        let value = currentClock + Float(Δ)
                            
        //since closure is executed on background thread, dispatch back to the main thread
        DispatchQueue.main.async { self.timeComponents = value.timeComponents() }
    }
    
    func updateCurrentClock(runningOnly:Bool) {
        if runningOnly {
            guard state == .running else { return }
            let elapsedSinceStart = Float(Date().timeIntervalSince(currentPair!.start))
            currentClock += elapsedSinceStart
        }
    }
}

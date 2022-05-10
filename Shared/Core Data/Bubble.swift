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
            if sessions_.isEmpty || lastSession.isEnded { return .brandNew }
            else {
                if lastPair!.pause == nil { return .running }
                else { return .paused }
            }
        }
    }
    
    var sessions_:[Session] {
        sessions?.array as? [Session] ?? []
    }
    
    ///lastSession is not always currentSession
    var lastSession:Session { sessions_.last! }
    
    var lastPair:Pair? { (lastSession.pairs?.array as? [Pair])?.last }
    
    // MARK: -
    ///what bubbleCell displays. ex: "12"hr "34"min "59"sec
    @Published var bubbleCellComponents
    = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "00")
    { willSet { self.objectWillChange.send() }}
    
    ///updates elapsed time inside PairCell. what smallBubbleCell displays. ex: "0"hr "12"min "24"sec
    @Published var smallBubbleCellComponents
    = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "00")
    { willSet { self.objectWillChange.send() }}
        
    private(set) var isObservingBackgroundTimer = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("bubble deinit")
    }
    
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
    
    var shouldUpdateSmallBubbleCellTimeComponents = false
}

// MARK: - Observers
extension Bubble {
    enum ObserveState {
        case start
        case stop
    }
    
    ///set bubble.timeComponents. called [once] on app launch
    func observeAppLaunch(_ observe:ObserveState) {
        switch observe {
            case .start:
                NotificationCenter.default.addObserver(forName: .appLaunched, object: nil, queue: nil) { [weak self] notification in
                    guard let self = self else { return }
                                                            
                    let componentsString = self.currentClock.timComponentsAsStrings
                    DispatchQueue.main.async { self.bubbleCellComponents = componentsString }
                }
            default: NotificationCenter.default.removeObserver(self)
        }
    }
    
    ///observe backgroundtimer signal. update time components only if bubble is running
    func observeBackgroundTimer() { isObservingBackgroundTimer = true
        NotificationCenter.default.addObserver(forName: .timerSignal, object: nil, queue: nil) {
            
            [weak self] _ in
            self?.updateBubbleCellTimeComponents()
            self?.updateSmallBubbleCellTimeComponents()
        }
    }
    
    private func updateBubbleCellTimeComponents() {
        if state != .running { return }
        guard let lastPairStart = lastPair!.start else { return }
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(lastPairStart)
        let value = currentClock + Float(Δ)
        let componentsString = value.timComponentsAsStrings
                            
        //since closure is executed on background thread, dispatch back to the main thread
        DispatchQueue.main.async { self.bubbleCellComponents = componentsString }
    }
    
    private func updateSmallBubbleCellTimeComponents() {
        if state != .running, !shouldUpdateSmallBubbleCellTimeComponents { return }
        guard let lastPairStart = lastPair!.start else { return }
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(lastPairStart)
        let componentsString = Float(Δ).timComponentsAsStrings
        
        DispatchQueue.main.async { self.smallBubbleCellComponents = componentsString }
    }
    
    func updateCurrentClock(runningOnly:Bool) {
        if runningOnly {
            guard state == .running else { return }
            
            let elapsedSinceStart = Float(Date().timeIntervalSince(lastPair?.start ?? Date()))
            currentClock += elapsedSinceStart
        }
    }
}

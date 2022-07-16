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

extension Bubble {
    func toggleStartDelay() {
        if startDelayBTimer == nil {
            let bTimer:BackgroundTimer = {
                let timer = BackgroundTimer(dispatchQueue)
                
                return timer
            }()
            self.startDelayBTimer = bTimer
        } else {
            self.startDelayBTimer = nil
        }
    }
}

public class Bubble: NSManagedObject {
    
    lazy var dispatchQueue = DispatchQueue(label: "startDelayBTimerDQ")
    var startDelayBTimer:BackgroundTimer?
    
    ///4 start delay values
    static let delays = [5, 10, 20, 45]
    
    // MARK: - Testing Only
    var signalReceived:Date?
    var componentsUpdated:Date?
    
    // MARK: -
    var sessions_:[Session] {
        get { sessions?.array as? [Session] ?? [] }
        set { sessions = NSOrderedSet(array: newValue) }
    }
    
    var history_:[BubbleSavedNote] { history?.array as? [BubbleSavedNote] ?? [] }
    
    ///lastSession is not always currentSession
    var lastSession:Session? { sessions_.last }
    
    ///lastPair of lastSession
    var lastPair:Pair? { (lastSession?.pairs?.array as? [Pair])?.last }
    
    // MARK: -
    ///@Published time components that bubbleCell displays. ex: "12"hr "34"min "59"sec
    @Published var bCell_Components
    = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "00")
    { willSet { self.objectWillChange.send() }}
    
    ///updates elapsed time inside PairCell. what smallBubbleCell displays. ex: "0"hr "12"min "24"sec
    @Published var smallBubbleView_Components
    = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "00")
    { willSet { DispatchQueue.main.async { self.objectWillChange.send() } }}
        
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
    
    //shouldUpdateSmallBubbleCellTimeComponents
    var continueToUpdateSmallBubbleCell = false {didSet{
        if !continueToUpdateSmallBubbleCell { smallBubbleView_Components = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "0") }
    }}
}

extension Bubble {
    enum State {
        case brandNew //0
        case running //1
        case paused //2
        case finished //3 timers only
    }
    
    var state:State {
        guard let lastSession = lastSession else { return .brandNew }
        
        if kind != .stopwatch && currentClock <= 0 { return .finished }
        else {
            if sessions_.isEmpty || lastSession.isEnded { return .brandNew }
            else {
                if lastPair!.pause == nil { return .running }
                else { return .paused }
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
    
    ///observe backgroundtimer signal to update time components only if bubble is running
    func observeBackgroundTimer() {
        isObservingBackgroundTimer = true
        
        NotificationCenter.default
            .addObserver(forName: .timerSignal, object: nil, queue: nil) {
                [weak self] _ in
                
                self?.updateBubbleCellComponents()
                self?.updateSmallBubbleCell()
            }
    }
    
    ///time components hr:min:sec:hundredths
    private func updateBubbleCellComponents() {
        if state != .running { return }
        
        guard let lastPairStart = lastPair!.start else { return }
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(lastPairStart)
        let value = currentClock + Float(Δ)
        let componentsString = value.timeComponentsAsStrings
                                    
        //since closure runs on bThread, dispatch back to mThread
        DispatchQueue.main.async { self.bCell_Components = componentsString }
    }
    
    ///update smallBubbleCell time components: hr min sec
    private func updateSmallBubbleCell() {
        if !continueToUpdateSmallBubbleCell, state != .running { return }
        guard let lastPairStart = lastPair?.start else { return }
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(lastPairStart)
        let componentsString = Float(Δ).timeComponentsAsStrings
        
        DispatchQueue.main.async { self.smallBubbleView_Components = componentsString }
    }
    
    func updateCurrentClock(runningOnly:Bool) {
        if runningOnly {
            guard state == .running else { return }
            
            let elapsedSinceStart = Float(Date().timeIntervalSince(lastPair?.start ?? Date()))
            currentClock += elapsedSinceStart
        }
    }
}

extension Bubble {
    var note_:String {
        get { note ?? "" }
        set { note = newValue }
    }
}

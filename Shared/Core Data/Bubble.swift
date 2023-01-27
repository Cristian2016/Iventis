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
import MyPackage

public class Bubble: NSManagedObject {
    
    private var observerAddedAlready = false
    
    ///4 start delay values
    static let delays = [5, 10, 20, 45]
        
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
    //Published time components that bubbleCell displays. ex: "12"hr "34"min "59"sec
    @Published var components
    = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "00")
    { willSet { self.objectWillChange.send() }}
    
    //updates elapsed time inside PairCell. what smallBubbleCell displays. ex: "0"hr "12"min "24"sec
    @Published var smallBubbleView_Components
    = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "00")
    { willSet { DispatchQueue.main.async { self.objectWillChange.send() } }}
            
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
    var syncSmallBubbleCell = false {didSet{
        if !syncSmallBubbleCell { smallBubbleView_Components = Float.TimeComponentsAsStrings(hr: "0", min: "0", sec: "0", cents: "0") }
    }}
}

extension Bubble {
    enum State: String {
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
        
    ///observe bubbleTimer signal to update time components only if bubble is running
    ///1.start observing on init, 2.resume observing on reentering active phase 3.remove observer on deinit
    func addObserver() {
        //make sure observer added only once
        if observerAddedAlready { return }
        observerAddedAlready = true
        
        NotificationCenter.default
            .addObserver(forName: .bubbleTimerSignal, object: nil, queue: nil) {
                [weak self] _ in
                guard self?.state == .running else { return }
                
                self?.updateBubbleCellComponents()
                self?.updateSmallBubbleCell()
            }
    }
    
    ///time components hr:min:sec:hundredths
    private func updateBubbleCellComponents() {
        guard let lastPairStart = lastPair!.start else { return }
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(lastPairStart)
        let value = currentClock + Float(Δ)
        let componentsString = value.timeComponentsAsStrings
                                    
        //since closure runs on bThread, dispatch back to mThread
        DispatchQueue.main.async { self.components = componentsString }
    }
    
    ///update smallBubbleCell time components: hr min sec
    private func updateSmallBubbleCell() {
        if !syncSmallBubbleCell { return }
        guard let lastPairStart = lastPair?.start else { return }
        
        //delta: elapsed duration between pair.start and signal dates
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

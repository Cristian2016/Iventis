//
//  Bubble+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//
//1 observe BackgroundTimer.signal [Notifications]. start observing when bubble is created, stop on deinit
//https://www.advancedswift.com/core-data-background-fetch-save-create/

import Foundation
import CoreData
import SwiftUI
import MyPackage

@objc(Bubble)
public class Bubble: NSManagedObject {
    
    lazy var coordinator:BubbleCellCoordinator! = BubbleCellCoordinator(for: self)
    lazy var pairBubbleCellCoordinator:PairBubbleCellCoordinator! = PairBubbleCellCoordinator(bubble: self)

    ///4 start delay values
    static let delays = [5, 10, 20, 45]
        
    // MARK: - Convenience
    var sessions_:[Session] {
        get { sessions?.array as? [Session] ?? [] }
        set { sessions = NSOrderedSet(array: newValue) }
    }
        
    var history_:[BubbleSavedNote] { history?.array as? [BubbleSavedNote] ?? [] }
    
    ///lastSession is not always currentSession
    var lastSession:Session? { sessions_.last }
    
    ///lastPair of lastSession
    var lastPair:Pair? { (lastSession?.pairs?.array as? [Pair])?.last }
                
    deinit { NotificationCenter.default.removeObserver(self) } //1
    
    enum Kind:Comparable {
        case stopwatch
        case timer(Float)
    }
    
    var kind:Kind { initialClock == 0 ? .stopwatch : .timer(initialClock) }
    
    var isTimer:Bool { kind != .stopwatch }
}

extension Bubble {
    enum State: String {
        case brandNew //0
        case running //1
        case paused //2
        case finished //3 timers only
    }
    
    // TODO: verify state. make sure it's correct
    var state:State {
        //if sessions.isEmpty state is .brandNew
        guard let lastSession = lastSession else { return .brandNew }
        
        //only timers can have .finished state. timers where .currentClock <= 0 are finished
        if kind != .stopwatch && currentClock <= 0 && !sessions_.isEmpty { return .finished }
        else {
            if sessions_.isEmpty || lastSession.isEnded { return .brandNew }
            else {
                if lastPair!.pause == nil { return .running }
                else { return .paused }
            }
        }
    }
    
    func updateCurrentClock(runningOnly:Bool) {
        if runningOnly {
            guard state == .running else { return }
            
            let elapsedSinceStart = Float(Date().timeIntervalSince(lastPair?.start ?? Date()))
            currentClock += elapsedSinceStart
        }
    } //1
    
    var note_:String {
        get { note ?? "" }
        set { note = newValue }
    }
}

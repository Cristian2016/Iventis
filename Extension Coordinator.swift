//
//  Extension Coordinator.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 20.01.2024.
//

import SwiftUI
import Combine
import MyPackage

extension BubbleCellCoordinator {
    func update(for action:UserAction) { //mainQueue
        
        guard let objID = bubble?.objectID else { return }
        
        PersistenceController.shared.bContext.perform {
            let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            switch action {
                case .start:
                    self.publisher = NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
                    self.publisher?
                        .sink { //repeats each seconds
                            [weak self] _ in
                            self?.task(bBubble)
                        }
                        .store(in: &self.cancellable) //connect
                    
                case .pause:
                    self.stopRepetitiveTask()
                    
                    let theInitialValue = self.updatedCurrentClock(bBubble)
                    let components = theInitialValue.componentsAsString
                    let hr = components.hr
                    let min = components.min
                    let sec = components.sec
                    let hundredths = components.hundredths
                    
                    DispatchQueue.main.async {
                        self.components = Components(hr, min, sec, hundredths)
                        self.opacity.update(for: theInitialValue)
                    }
                    
                case .closeSession, .reset, .currentSessionDelete:
                    let components = bBubble.isTimer ? bBubble.initialClock.componentsAsString : .zeroAll
                    let currentClock = bBubble.isTimer ? self.updatedCurrentClock(bBubble) : 0.0
                    
                    DispatchQueue.main.async {
                        self.stopRepetitiveTask()
                        
                        self.timerProgress = "OK"
                        self.components = .init(components.hr, components.min, components.sec, "00")
                        self.opacity.update(for:currentClock)
                    }
                    
                case .bubbleDelete:
                    DispatchQueue.main.async { self.stopRepetitiveTask() }
                    NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    enum UserAction {
        case start
        case pause
        case reset
        case closeSession
        case bubbleDelete
        case currentSessionDelete
    }
        
    internal func task(_ bubble:Bubble?) { //bQueue
        guard
            let bubble = bubble,
            let lastStart = bubble.lastPair?.start else { return }

        let currentClock = bubble.currentClock
        
        let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart)) //2
                
        var updatedCurrentClock =  isTimer ? currentClock - elapsedSinceLastStart :
        currentClock + elapsedSinceLastStart
        
        updatedCurrentClock.round(.toNearestOrEven) //ex: 2346
        
        if isTimer {
            //1. compute progress
            let progress = self.computeTimerProgress(for: bubble, and: updatedCurrentClock)
            DispatchQueue.main.async {
                self.timerProgress = String(format: "%.2f", progress)
            }
            
            //2. check if timer should finish
            let lastBubbleDuration = bubble.lastSession!.lastBubbleDuration
            let elapsedSinceFirstStart = lastBubbleDuration + elapsedSinceLastStart
            let overspill = bubble.initialClock - elapsedSinceFirstStart //
            
            if (Float(0)...1).contains(overspill) {//app is active
                let deadline:DispatchTime = .now() + .milliseconds(Int(overspill * 1000))
                
                precisionTimer.executeAction(after: deadline) { [weak self] in
                    reportBlue(bubble, "coordinator.task. detected kill timer no overspill")
                    self?.requestKillTimer() //at exactly 0.0 overspill
                }
            } else {//app becomes active
                if overspill < 0 {
                    reportBlue(bubble, "coordinator.task.detected kill timer with overspill")
                    self.requestKillTimer(overspill)
                }
            }
        }
        
        let intValue = Int(updatedCurrentClock)
        let secValue = intValue%60
        
        let refreshForTimer = isTimer && secValue == 59
        
        if secValue == 0 || refreshForTimer { //send minutes and hours
            let giveMeAName = intValue/60%60
            let minValue = String(giveMeAName)
            
            DispatchQueue.main.async { //send min
                self.components.min = minValue
                if intValue == 60 { self.opacity.update(for: updatedCurrentClock) }
            }
            
            if (giveMeAName%60) == 0 || refreshForTimer {
                let hrValue = String(intValue/3600)
                
                DispatchQueue.main.async { //send hour
                    self.components.hr = hrValue
                    if intValue == 3600 || refreshForTimer {
                        self.opacity.update(for: updatedCurrentClock)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.components.sec = String(secValue) //send seconds
        }
    } //4
}

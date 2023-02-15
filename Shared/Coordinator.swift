//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//1 publishers emit their initial value, without .send()! ⚠️
//2 delta is the elapsed duration between last pair.start and signal date
//3 create means initialization. 1.user creates a bubble or 2.bubble created already but app relaunches
//4 every second publisher sends out bTimer signal and this is the task to run. bubble.currentClock + ∆

import SwiftUI
import Combine

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

class BubbleCellCoordinator {
    private func update(_ action:Action) {
        switch action {
            case .start:
                publisher
                    .sink { [weak self] _ in self?.continuousUpdate() }
                    .store(in: &cancellable) //connect
            case .pause:
                oneTimeUpdate()
                cancellable = [] //disconnect
        }
    }
    
    private func continuousUpdate() {
        guard let lastPairStart = bubble.lastPair?.start else { return }

        DispatchQueue.global().async {
            let Δ = Date().timeIntervalSince(lastPairStart) //2
            var value = self.bubble.currentClock + Float(Δ) //ex: 2345.87648
            
            value.round(.toNearestOrEven) //ex: 2346
            
            let intValue = Int(value)
            let secValue = intValue%60
            
            //send minute and hour
            if secValue == 0 {
                let giveMeAName = intValue/60%60
                let minValue = String(giveMeAName)
                
                DispatchQueue.main.async {
                    self.minPublisher.send(minValue)
                    if intValue > 0 {
                        self.opacityPublisher.send([.min(.show)])
                    }
                }
                
                //send hour
                if (giveMeAName%60) == 0 {
                    let hrValue = String(intValue/3600)
                    DispatchQueue.main.async { self.hrPublisher.send(hrValue) }
                }
            }
            
            //send each second
            DispatchQueue.main.async {
                self.secPublisher.send(String(secValue))
            }
        }
        
    } //4
    
    private func oneTimeUpdate() {
        DispatchQueue.global().async {
            let initialValue = self.initialValue
            print(initialValue, " initial value \(self.bubble.color!)")
            let stringComponents = initialValue.timeComponentsAsStrings
                                
            DispatchQueue.main.async {
                self.secPublisher.send(stringComponents.sec)
                self.minPublisher.send(stringComponents.min)
                self.hrPublisher.send(stringComponents.hr)
                self.centsPublisher.send(stringComponents.cents)
                
                if self.bubble.kind == .stopwatch {
                    self.setOpacity(for: initialValue)
                } else {
                    self.opacityPublisher.send([.min(.show), .hr(.show)])
                }
            }
//            print("\(self.bubble.color!) \(self.bubble.currentClock)")
        }
    }
    
    // MARK: - Publishers 1
    var opacityPublisher:Publisher<[Component], Never> = .init([.min(.hide), .hr(.hide)])
    
    private var colorPublisher:Publisher<Color, Never> = .init(.blue)
    
    var secPublisher:Publisher<String, Never> = .init("-1")
    var minPublisher:Publisher<String, Never>! = .init("-1")
    var hrPublisher:Publisher<String, Never>! = .init("-1")
    var centsPublisher:Publisher<String, Never>! = .init("-1")
    
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: -
    private let bubble:Bubble
    
    private func setOpacity(for initialValue: Float) {
        if initialValue >= 60 {
            opacityPublisher.send([.min(.show)])
        }
        if initialValue >= 3600 {
            opacityPublisher.send([.min(.show), .hr(.show)])
        }
    }
    
    func updateComponents(_ moment:Moment) {
        DispatchQueue.global().async {
            
            switch moment {
                case .automatic:
                    if self.bubble.state == .running { self.update(.start) }
                    
                case .user(let action):
                    switch action {
                        case .pause: self.update(.pause)
                        case .start: self.update(.start)
                    }
                    
                case .create:
                    let currentClock = self.bubble.currentClock
                    let stringComponents = currentClock.timeComponentsAsStrings
                                        
                    DispatchQueue.main.async {
                        self.secPublisher.send(stringComponents.sec)
                        self.minPublisher.send(stringComponents.min)
                        self.hrPublisher.send(stringComponents.hr)
                        self.centsPublisher.send(stringComponents.cents)
                        
                        if self.bubble.kind == .stopwatch {
                            self.setOpacity(for: currentClock)
                        } else {
                            self.opacityPublisher.send([.min(.show), .hr(.show)])
                        }
                    }
                case .endSession, .reset:
                    self.cancellable = []
                    let initialClock = self.bubble.initialClock
                    let stringComponents = initialClock.timeComponentsAsStrings
                    
                    DispatchQueue.main.async {
                        self.secPublisher.send(stringComponents.sec)
                        self.minPublisher.send(stringComponents.min)
                        self.hrPublisher.send(stringComponents.hr)
                        self.centsPublisher.send(stringComponents.cents)
                        
                        if self.bubble.kind == .stopwatch {
                            self.opacityPublisher.send([.min(.hide), .hr(.hide)])
                        } else {
                            self.opacityPublisher.send([.min(.show), .hr(.show)])
                        }
                    }
                    
                default : break
            }
        }
    }
        
    private var initialValue:Float {
            if bubble.state == .running {
                let Δ = Date().timeIntervalSince(bubble.lastPair!.start!)
                let initialValue = bubble.currentClock + Float(Δ)
                return initialValue
            } else {
                return bubble.currentClock
            }
    }
    
    init(for bubble:Bubble) {
        self.bubble = bubble
        oneTimeUpdate()
        print("init update")
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
    }
}

extension BubbleCellCoordinator {
    ///automatic means handled by the system. ex. when app launches
    enum Moment {
        case automatic
        case user(Action)
        case create //3
        case reset
        case endSession
    }
    
    enum Action {
        case start
        case pause
    }
    
    enum Component {
        case min(Show)
        case hr(Show)
    }
    
    enum Show {
        case show
        case hide
    }
}

//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//1 publishers emit their initial value, without .send()! ⚠️
//2 delta is the elapsed duration between last pair.start and signal date
//3 create means initialization. 1.user creates a bubble or 2.bubble created already but app relaunches
//4 every second publisher sends out bTimer signal and this is the task to run. bubble.currentClock + ∆
//5 lets continuousUpdate do one pass to refresh all components

import SwiftUI
import Combine

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

class BubbleCellCoordinator {
    
    @Published private(set) var components = Components(hr: "-1", min: "-1", sec: "-1", hundredths: "-1")
    @Published private(set) var opacity = Opacity()
    
    struct Components {
        var hr:String
        var min:String
        var sec:String
        var hundredths:String
    }
    
    struct Opacity {
        var hr = CGFloat(0)
        var min = CGFloat(0)
        
        mutating func update(_ value:Float) {
            min = value > 59 ? 1 : 0
            hr = value > 3599 ?  1 : 0
        }
    }
    
    private func update(_ action:Action) {
        switch action {
            case .start:
                DispatchQueue.main.async {
                    self.components.hundredths = ""
                }

                publisher
                    .sink { [weak self] _ in self?.continuousUpdate() }
                    .store(in: &cancellable) //connect
            case .pause:
                cancellable = [] //disconnect
        }
    }
    
    var refresh /* all components */ = false //5
    
    private func continuousUpdate() {
        guard let lastPairStart = bubble.lastPair?.start else { return }

        DispatchQueue.global().async {
            let Δ = Date().timeIntervalSince(lastPairStart) //2
            var value = self.bubble.currentClock + Float(Δ) //ex: 2345.87648
            
            value.round(.toNearestOrEven) //ex: 2346
            
            let intValue = Int(value)
            let secValue = intValue%60
            
            //send minute and hour
            if secValue == 0 || self.refresh {
                let giveMeAName = intValue/60%60
                let minValue = String(giveMeAName)
                
                
                //send min
                DispatchQueue.main.async {
                    self.components.min = minValue
                    if intValue == 60 {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                            self.opacity.update(value)
                        }
                    }
                }
                
                if (giveMeAName%60) == 0 || self.refresh {
                    let hrValue = String(intValue/3600)
                    
                    //send hour
                    DispatchQueue.main.async {
                        self.components.hr = hrValue
                        if intValue == 3600 || self.refresh {
                            withAnimation {
                                self.opacity.update(value)
                            }
                        }
                    }
                }
            }
            
            //send second
            DispatchQueue.main.async {
                self.components.sec = String(secValue)
            }
            
            self.refresh = false
        }
        
    } //4
    
    // MARK: - Publishers 1
    
    var colorPublisher:Publisher<Color, Never>
        
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    var cancellable = Set<AnyCancellable>()
    
    // MARK: -
    unowned private let bubble:Bubble
    
    func updateComponents(_ moment:Moment) {
        DispatchQueue.global().async {
            
            switch moment {
                case .user(let action):
                    switch action {
                        case .pause: self.update(.pause)
                        case .start: self.update(.start)
                    }
                                        
                case .endSession, .reset, .deleteLastSession:
                    self.cancellable = []
                    let initialClock = self.bubble.initialClock
                    let stringComponents = initialClock.timeComponentsAsStrings
                    
                    DispatchQueue.main.async {
                        self.components.hr = stringComponents.hr
                        self.components.min = stringComponents.min
                        self.components.sec = stringComponents.sec
                        self.components.hundredths = stringComponents.hundredths
                        
                        if self.bubble.kind == .stopwatch {
                            self.opacity.update(0)
                        } else {
                            self.opacity.update(self.bubble.initialClock)
                        }
                    }
            }
        }
    }
    
    func updateAtPause()  {
        cancellable = []
        DispatchQueue.global().async {
            let components = self.initialValue.timeComponentsAsStrings
            
            DispatchQueue.main.async {
                self.components = Components(hr: components.hr,
                                             min: components.min,
                                             sec: components.sec,
                                             hundredths: components.hundredths)
            }
        }
    }
        
    var initialValue:Float {
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
        self.colorPublisher = .init(Color.bubbleColor(forName: bubble.color))
                
        observeActivePhase()
        
        //set initial values when bubble is created [ViewModel.createBubble]
        DispatchQueue.global().async {
            let components = self.initialValue.timeComponentsAsStrings
            
            self.components = Components(hr: components.hr,
                                         min: components.min,
                                         sec: components.sec,
                                         hundredths: components.hundredths
            )
            self.opacity.update(self.initialValue)
        }
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
    }
    
    private func observeActivePhase() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            DispatchQueue.global().async {
                let components = self.initialValue.timeComponentsAsStrings
                
                DispatchQueue.main.async {
                    self.components = Components(hr: components.hr,
                                                 min: components.min,
                                                 sec: components.sec,
                                                 hundredths: components.hundredths
                    )
                    
                    self.opacity.update(self.initialValue)
                    
                    if self.bubble.state == .running { self.update(.start) }
                }
            }
        }
    }
}

extension BubbleCellCoordinator {
    ///automatic means handled by the system. ex. when app launches
    enum Moment {
        case user(Action)
        case reset
        case endSession
        case deleteLastSession
    }
    
    enum Action {
        case start
        case pause
    }
}

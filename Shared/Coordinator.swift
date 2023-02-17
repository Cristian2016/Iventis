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
    
    struct Components {
        var hr:String
        var min:String
        var sec:String
        var hundredths:String
    }
    
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
                            self.opacityPublisher.send([.min(.show)])
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
                                self.opacityPublisher.send([.hr(.show)])
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
    
    private func oneTimeUpdate() {
        DispatchQueue.global().async {
            let initialValue = self.initialValue
                                
            DispatchQueue.main.async {
                
                if self.bubble.kind == .stopwatch {
                    self.setOpacity(for: initialValue)
                } else {
                    self.opacityPublisher.send([.min(.show), .hr(.show)])
                }
            }
        }
    }
    
    // MARK: - Publishers 1
    var opacityPublisher:Publisher<[Component], Never> = .init([.min(.hide), .hr(.hide)])
    
    var colorPublisher:Publisher<Color, Never>
        
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    var cancellable = Set<AnyCancellable>()
    
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
                            self.opacityPublisher.send([.min(.hide), .hr(.hide)])
                        } else {
                            self.opacityPublisher.send([.min(.show), .hr(.show)])
                        }
                    }
            }
        }
    }
    
    func updateAtPause()  {
        cancellable = []
        DispatchQueue.global().async {
            let components = self.initialValue.timeComponentsAsStrings
            self.components = Components(hr: components.hr,
                                         min: components.min,
                                         sec: components.sec,
                                         hundredths: components.hundredths)
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
        
        DispatchQueue.global().async {
            let components = self.initialValue.timeComponentsAsStrings
            self.components = Components(hr: components.hr,
                                         min: components.min,
                                         sec: components.sec,
                                         hundredths: components.hundredths
            )
            
            if bubble.state == .running { self.update(.start) }
        }
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
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
    
    enum Component {
        case min(Show)
        case hr(Show)
    }
    
    enum Show {
        case show
        case hide
    }
}

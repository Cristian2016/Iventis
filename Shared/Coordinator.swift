//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//1 publishers emit their initial value, without .send()! ⚠️
//2 delta is the elapsed duration between last pair.start and signal date
//3 create means initialization. 1.user creates a bubble or 2.bubble created already but app relaunches
//4 repetitive task() called each second. every second publisher sends out bTimer signal and this is the task to run. bubble.currentClock + ∆. maybe in the future I decide to call this task every 0.5 seconds.. maybe :)
//5 lets continuousUpdate do one pass to refresh all components
//6 evaluate before creating a new session, otherwise the value will be alwatys false

import SwiftUI
import Combine

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

class BubbleCellCoordinator {
    weak private var bubble:Bubble?
    
    // MARK: - Public API
    func update(_ moment:Moment) {
        guard let bubble = bubble else { return }
        
        DispatchQueue.global().async {
            switch moment {
                case .showAll:
                    if bubble.state == .running && !bubble.isPinned {
                        self.refresh = true
                        print("refresh for \(bubble.color ?? "pula color")")
                    }
                    
                case .automatic:
                    DispatchQueue.main.async { self.components.hundredths = "" }
                    self.refresh = true
                    self.publisher
                        .sink { [weak self] _ in self?.task() }
                        .store(in: &self.cancellable) //connect
                    
                case .user(let action):
                    switch action {
                        case .pause:
                            self.cancellable = []
                            DispatchQueue.global().async {
                                let components = self.initialValue.timeComponentsAsStrings
                                
                                DispatchQueue.main.async {
                                    self.components = Components(components.hr,
                                                                 components.min,
                                                                 components.sec,
                                                                 components.hundredths)
                                }
                            }
                            
                        case .start:
                            self.refresh = false
                            self.publisher
                                .sink { [weak self] _ in self?.task() }
                                .store(in: &self.cancellable) //connect
                            DispatchQueue.main.async { self.components.hundredths = "" }
                            
                        case .endSession, .reset, .deleteCurrentSession:
                            self.cancellable = []
                            let initialClock = bubble.initialClock
                            let stringComponents = initialClock.timeComponentsAsStrings
                            
                            DispatchQueue.main.async {
                                self.components.hr = stringComponents.hr
                                self.components.min = stringComponents.min
                                self.components.sec = stringComponents.sec
                                self.components.hundredths = stringComponents.hundredths
                                
                                if bubble.kind == .stopwatch {
                                    self.opacity.update(0)
                                } else {
                                    self.opacity.update(bubble.initialClock)
                                }
                            }
                            
                        case .deleteBubble:
                            self.cancellable = []
                            NotificationCenter.default.removeObserver(self)
                    }
            }
        }
    }
    
    @Published private(set) var components = Components("-1", "-1", "-1", "-1")
    @Published private(set) var opacity = Opacity()
    var colorPublisher:Publisher<Color, Never>
    
    // MARK: - Private API
    private var refresh /* all components */ = false //5
    
    private func task() {
        guard
            let bubble = self.bubble,
            let lastPairStart = bubble.lastPair?.start else { return }
        
        DispatchQueue.global().async {
            let Δ = Date().timeIntervalSince(lastPairStart) //2
            var value = bubble.currentClock + Float(Δ) //ex: 2345.87648
            
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
                            withAnimation { self.opacity.update(value) }
                        }
                    }
                }
            }
            
            //send second
            DispatchQueue.main.async { self.components.sec = String(secValue) }
            
            self.refresh = false
        }
        
    } //4
    
    // MARK: - Publishers 1
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>()
        
    private var initialValue:Float {
        guard let bubble = bubble else { fatalError() }
        if bubble.state == .running {
            let Δ = Date().timeIntervalSince(bubble.lastPair!.start!)
            let initialValue = bubble.currentClock + Float(Δ)
            return initialValue
        } else {
            return bubble.currentClock
        }
    }
    
    // MARK: - Observers
    private func observeActivePhase() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            
            guard
                let bubble = self?.bubble,
                let self = self else { return }
            
            DispatchQueue.global().async {
                let components = self.initialValue.timeComponentsAsStrings
                
                DispatchQueue.main.async {
                    self.components = Components(components.hr,
                                                 components.min,
                                                 components.sec,
                                                 components.hundredths
                    )
                    
                    self.opacity.update(self.initialValue)
                    
                    if bubble.state == .running { self.update(.automatic) }
                }
            }
        }
    }
    
    // MARK: - Init Deinit
    init(for bubble:Bubble) {
        self.bubble = bubble
        self.colorPublisher = .init(Color.bubbleColor(forName: bubble.color))
        
        observeActivePhase()
        
        //set initial values when bubble is created [ViewModel.createBubble]
        DispatchQueue.global().async {
            let components = self.initialValue.timeComponentsAsStrings
            
            self.components = Components(components.hr,
                                         components.min,
                                         components.sec,
                                         components.hundredths)
            self.opacity.update(self.initialValue)
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
        case automatic
        case showAll //show all bubbles, including the ordinary ones
    }
    
    enum Action {
        case start
        case pause
        case reset
        case endSession
        case deleteCurrentSession
        case deleteBubble
    }
    
    struct Components {
        var hr:String
        var min:String
        var sec:String
        var hundredths:String
        
        init(_ hr:String, _ min:String, _ sec:String, _ hundredths:String) {
            self.hr = hr
            self.min = min
            self.sec = sec
            self.hundredths = hundredths
        }
    }
    
    struct Opacity {
        var hr = CGFloat(0)
        var min = CGFloat(0)
        
        mutating func update(_ value:Float) {
            min = value > 59 ? 1 : 0.001
            hr = value > 3599 ?  1 : 0.001
        }
    }
}

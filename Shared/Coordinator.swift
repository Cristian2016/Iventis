//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//1 publishers emit their initial value, without .send()! ⚠️

import SwiftUI
import Combine

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

class BubbleCellCoordinator {
    func update(_ action:Action) {
        switch action {
            case .start:
                publisher
                    .sink { [weak self] _ in self?.handler() }
                    .store(in: &cancellable)
            case .pause:
                cancellable = []
        }
    }
    
    ///every second publisher sends out bTimer signal and this is the task to run
    private func handler() {
        guard let lastPairStart = bubble.lastPair?.start else { return }
                
        //delta is the elapsed duration between last pair.start and signal date
        let Δ = Date().timeIntervalSince(lastPairStart)
        var value = bubble.currentClock + Float(Δ) //ex: 2345.87648
        value.round(.toNearestOrEven) //ex: 2346
        let intValue = Int(value)
        let secValue = intValue%60
        
        //send minute and hour
        if secValue == 0 {
            let giveMeAName = intValue/60%60
            let minValue = String(giveMeAName)
            DispatchQueue.main.async {
                self.minPublisher.send(minValue)
                self.opacityPublisher.send([.min(.show)])
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
    
    // MARK: - Publishers 1
    var opacityPublisher:Publisher<[Component], Never> = .init([.min(.hide), .hr(.show)])
    
    var colorPublisher:Publisher<Color, Never> = .init(.blue)
    
    var componentsPublisher:Publisher<Float.TimeComponentsAsStrings, Never> = .init(.zeroAll)
    
    var secPublisher:Publisher<String, Never> = .init("-1")
    var minPublisher:Publisher<String, Never>! = .init("-1")
    var hrPublisher:Publisher<String, Never>! = .init("-1")
    var centsPublisher:Publisher<String, Never>! = .init("-1")
    
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: -
    let bubble:Bubble
    
    enum Moment {
        case appLaunch
        case appActive
    }
    
    func updateComponents(_ moment:Moment) {
        DispatchQueue.global().async {
            
            let value = self.initialValue
            switch moment {
                case .appLaunch:
                    let components = value.timeComponentsAsStrings
                    
                    let minOpacity = value >= 60 ? Component.min(.show) : .min(.hide)
                    let hrOpacity = value >= 3600  ? Component.hr(.show) : .hr(.hide)
                    
                    //update any bubble (running or notRunning)
                    DispatchQueue.main.async {
                        //labels update
                        self.secPublisher.send(components.sec)
                        self.minPublisher.send(components.min)
                        self.hrPublisher.send(components.hr)
                        if self.bubble.state != .running {
                            self.centsPublisher.send(components.cents)
                        }
                        self.opacityPublisher.send([minOpacity, hrOpacity])
                    }
                    
                    if self.bubble.state == .running { self.update(.start) }
                    
                case .appActive:
                    let components = value.timeComponentsAsStrings
                    DispatchQueue.main.async {
                        if self.bubble.state != .running {
                            self.secPublisher.send(components.sec)
                            self.minPublisher.send(components.min)
                            self.hrPublisher.send(components.hr)
                            self.centsPublisher.send(components.cents)
                        } else {
                            
                        }
                    }
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
    
    init(for bubble:Bubble) { self.bubble = bubble }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
    }
    
    enum Action {
        case start
        case pause
    }
}

extension BubbleCellCoordinator {
    enum Component {
        case min(Show)
        case hr(Show)
    }
    
    enum Show {
        case show
        case hide
        
    }
}

//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//

import SwiftUI
import Combine

class BubbleCellCoordinator {
    // MARK: - Publishers
    //they emit their initial value, without .send()! ⚠️
    var visibilityPublisher:CurrentValueSubject<[Component], Never> = .init([.min(.hide), .hr(.show)])
    
    var colorPublisher:CurrentValueSubject<Color, Never> = .init(.blue)
    
    lazy var componentsPublisher:CurrentValueSubject<Float.TimeComponentsAsStrings, Never> = .init(bubble.currentClock.timeComponentsAsStrings)
    
    var secPublisher:CurrentValueSubject<String, Never>
    var minPublisher:CurrentValueSubject<String, Never>
    var hrPublisher:CurrentValueSubject<String, Never>
//    var centsPublisher:CurrentValueSubject<String, Never>
    
    // MARK: -
    let bubble:Bubble
    
    init(for bubble:Bubble) {
        self.bubble = bubble
        
        
        // TODO: make it run on backgroundThread
        let components = bubble.currentClock.timeComponentsAsStrings
        
        self.hrPublisher = .init(components.hr)
        self.minPublisher = .init(components.min)
        self.secPublisher = .init(components.sec)
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
        print("coord deinit")
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    func update(_ action:Action) {
        switch action {
            case .start:
                NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
                    .sink { [weak self] _ in
                        self?.updateComponents()
                    }
                    .store(in: &cancellable)
            case .pause:
                cancellable = []
                NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func updateComponents() {
        guard let lastPairStart = bubble.lastPair!.start else { return }
        
        //delta is the elapsed duration between last pair.start and signal date
        let Δ = Date().timeIntervalSince(lastPairStart)
        var value = bubble.currentClock + Float(Δ)
        value.round(.toNearestOrEven) //ex: 2345
        let intValue = Int(value)
        let secValue = intValue%60
        
        //send minute and hour
        if secValue == 0 {
            let giveMeAName = intValue/60%60
            let minValue = String(giveMeAName)
            DispatchQueue.main.async { self.minPublisher.send(minValue) }
            
            //send hour
            if (giveMeAName%60) == 0 {
                let hrValue = String(intValue/3600)
                DispatchQueue.main.async { self.hrPublisher.send(hrValue) }
            }
        }
        
        //send each second
        DispatchQueue.main.async { self.secPublisher.send(String(secValue)) }
    } //1
    
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

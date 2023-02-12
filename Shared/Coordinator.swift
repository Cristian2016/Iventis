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
    
    private var cancellable = Set<AnyCancellable>()
    
    ///on wake-up it starts observing backgroundTimer
    func wakeUp() {
        NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
            .sink { [weak self] _ in
                if self?.bubble.state != .running { return }
                self?.updateComponents()
            }
            .store(in: &cancellable)
    }
    
    private func updateComponents() {
        guard let lastPairStart = bubble.lastPair!.start else { return }
        
        //delta is the elapsed duration between last pair.start and signal date
        let Δ = Date().timeIntervalSince(lastPairStart)
        var value = bubble.currentClock + Float(Δ)
        value.round(.toNearestOrEven) //ex: 2345
        let intValue = Int(value)
        
        
        
        let sec = String(intValue%60)
        
        DispatchQueue.main.async { self.secPublisher.send(sec) }
    } //1
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
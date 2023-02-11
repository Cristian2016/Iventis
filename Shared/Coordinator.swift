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
    var visibilityPublisher:CurrentValueSubject<Show, Never> = .init(.none)
    
    var colorPublisher:CurrentValueSubject<Color, Never> = .init(.blue)
    
    lazy var componentsPublisher:CurrentValueSubject<Float.TimeComponentsAsStrings, Never> = .init(bubble.currentClock.timeComponentsAsStrings)
    
    // MARK: -
    private var show = Show.none
    let bubble:Bubble
    
    init(for bubble:Bubble) {
        self.bubble = bubble
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
        
        //delta is the elapsed duration between pair.start and signal dates
        let Δ = Date().timeIntervalSince(lastPairStart)
        let value = bubble.currentClock + Float(Δ)
        let componentsString = value.timeComponentsAsStrings
                                    
        //since closure runs on bThread, dispatch back to mThread
        DispatchQueue.main.async {
            self.componentsPublisher.send(componentsString)
        }
    } //1
}

extension BubbleCellCoordinator {
    enum Show {
        case min(Bool)
        case hr(Bool)
        case none
    }
}

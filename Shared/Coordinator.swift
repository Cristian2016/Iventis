//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//

import SwiftUI
import Combine

class BubbleCellCoordinator {
    func update(_ action:Action) {
        switch action {
            case .start:
                publisher
                    .sink { [weak self] _ in self?.updateComponents() }
                    .store(in: &cancellable)
            case .pause:
                cancellable = []
        }
    }
    
    // MARK: - Publishers
    //they emit their initial value, without .send()! ⚠️
    var visibilityPublisher:CurrentValueSubject<[Component], Never> = .init([.min(.hide), .hr(.show)])
    
    var colorPublisher:CurrentValueSubject<Color, Never> = .init(.blue)
    
    lazy var componentsPublisher:CurrentValueSubject<Float.TimeComponentsAsStrings, Never> = .init(bubble.currentClock.timeComponentsAsStrings)
    
    var secPublisher:CurrentValueSubject<String, Never> = .init("-1")
    var minPublisher:CurrentValueSubject<String, Never>! = .init("-1")
    var hrPublisher:CurrentValueSubject<String, Never>! = .init("-1")
    var centsPublisher:CurrentValueSubject<String, Never>! = .init("-1")
    
    // MARK: -
    let bubble:Bubble
        
    private func setInitialValue(completion: @escaping (Float) -> Void) {
        DispatchQueue.global().async { [weak self] in
            if self?.bubble.state == .running {
                let Δ = Date().timeIntervalSince(self?.bubble.lastPair?.start ?? Date())
                let initialValue = (self?.bubble.currentClock ?? 0) + Float(Δ)
                completion(initialValue)
            } else {
                let initialValue = self?.bubble.currentClock ?? 0
                completion(initialValue)
            }
        }
    }
    
    func updateAtAppLaunch() {
        DispatchQueue.global().async { [self] in
            
            if bubble.state == .running { //update with delta
                let Δ = Date().timeIntervalSince(bubble.lastPair!.start!)
                let value = bubble.currentClock + Float(Δ)
                let components = value.timeComponentsAsStrings
                
                DispatchQueue.main.async {
                    self.secPublisher.send(components.sec)
                    self.minPublisher.send(components.min)
                    self.hrPublisher.send(components.hr)
                }
                
            } else { //update with bubble.currentClock
                let components = bubble.currentClock.timeComponentsAsStrings
                
                if bubble.color! == "orange" {
                    print(components)
                }
                
                DispatchQueue.main.async {
                    self.secPublisher.send(components.sec)
                    self.minPublisher.send(components.min)
                    self.hrPublisher.send(components.hr)
                    self.centsPublisher.send(components.cents)
                }
            }
        }
    }
    
    init(for bubble:Bubble) { self.bubble = bubble }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>()
    
    ///every second
    private func updateComponents() {
        guard let lastPairStart = bubble.lastPair!.start else { return }
        
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
                self.visibilityPublisher.send([.min(.show)])
            }
            
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

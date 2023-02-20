//
//  PairBubbleCellCoordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.02.2023.
//1 if cancellable is set to emty set, it will stop updating
//2 unowned because Coordinator must always have a bubble. If bubble gets deinit, Coordinator deinits as well

import Combine
import Foundation
import UIKit

class PairBubbleCellCoordinator {
    unowned private let bubble:Bubble //2
    
    @Published private(set) var components = Components("0", "0", "0")
    
    
    init(bubble: Bubble) {
        self.bubble = bubble
        observe_detailViewVisible()
        observe_AppActive()
        self.refresh = true
    }
    
    deinit {
//        print("PairBubbleCellCoordinator deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    private func update() {
        guard let lastPairStart = bubble.lastPair?.start else { return }
        
        DispatchQueue.global().async {
            var Δ = Float(Date().timeIntervalSince(lastPairStart))
            
            Δ.round(.toNearestOrEven) //ex: 2346
                        
            let intValue = Int(Δ)
            let secValue = intValue%60
                        
            //send minute and hour
            if secValue == 0 || self.refresh {
                let giveMeAName = intValue/60%60
                let minValue = String(giveMeAName)
                
                DispatchQueue.main.async { self.components.min = minValue } //Min
                
                if (giveMeAName%60) == 0 || self.refresh {
                    let hrValue = String(intValue/3600)
                    
                    DispatchQueue.main.async { self.components.hr = hrValue } //Hr
                }
            }
            
            //send second
            DispatchQueue.main.async { self.components.sec = String(secValue) }
            
            self.refresh = false
        }
    }
    
    private var initialValue:Float {
        if bubble.state == .running {
            let Δ = Date().timeIntervalSince(bubble.lastPair!.start!)
            let initialValue = Float(Δ)
            return initialValue
        } else {
            return 0
        }
    }
    
    func update(_ moment:Moment) {
        switch moment {
            case .automatic:
                if shouldWork {
                    publisher
                        .sink { [weak self] _ in self?.update() }
                        .store(in: &cancellable)
                }
            case .user(let action) :
                switch action {
                    case .start:
                        refresh = false
                        publisher
                            .sink { [weak self] _ in
                                self?.update()
                            }
                            .store(in: &cancellable)
                    case .pause, .deleteCurrentSession, .endSession:
                        components = Components("0", "0", "0")
                        cancellable = []
                
                    case .reset:
                        components = Components("0", "0", "0")
                        cancellable = []
                }
        }
    }
    
    private var shouldWork = false {didSet{
        if shouldWork {
            update(.automatic)
        } else {
            update(.user(.pause))
        }
    }}
    
    private var refresh = false
    
    private func observe_detailViewVisible() {
        NotificationCenter.Publisher(center: .default, name: .detailViewVisible)
            .sink {
                let detailViewVisible = $0.userInfo!["detailViewVisible"] as! Bool
                let condition = detailViewVisible && self.bubble.state == .running
                self.shouldWork = condition ? true : false
                self.refresh = true
            }
            .store(in: &detailViewVisibleCancellable)
    }
    
    private func observe_AppActive() {
        NotificationCenter.default.addObserver(forName: .appActive, object: nil, queue: nil) { _ in
            self.refresh = true
        }
    }
    
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>() //1
    private var detailViewVisibleCancellable = Set<AnyCancellable>() //1
}

extension PairBubbleCellCoordinator {
    struct Components {
        var hr:String
        var min:String
        var sec:String
        
        init(_ hr: String, _ min: String, _ sec: String) {
            self.hr = hr
            self.min = min
            self.sec = sec
        }
    }
    
    enum Moment {
        case user(Action)
        case automatic
    }
    
    enum Action {
        case start
        case pause
        case reset
        case endSession
        case deleteCurrentSession
    }
}

//
//  PairBubbleCellCoordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.02.2023.
//1 if cancellable is set to emty set, it will stop updating
//2 unowned because Coordinator must always have a bubble. If bubble gets deinit, Coordinator deinits as well

import Combine
import Foundation

class PairBubbleCellCoordinator {
    unowned private let bubble:Bubble //2
    
    @Published private(set) var components = Components("-1", "-1", "-1")
    
    
    init(bubble: Bubble) {
        self.bubble = bubble
        observe_detailViewVisible()
    }
    
    deinit {
        print("PairBubbleCellCoordinator deinit")
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
                
                
                //send min
                DispatchQueue.main.async { self.components.min = minValue }
                
                if (giveMeAName%60) == 0 || self.refresh {
                    let hrValue = String(intValue/3600)
                    
                    //send hour
                    DispatchQueue.main.async { self.components.hr = hrValue }
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
            return bubble.currentClock
        }
    }
    
    func update(_ moment:Moment) {
        switch moment {
            case .automatic:
                publisher
                    .sink { [weak self] _ in
                        self?.update()
                    }
                    .store(in: &cancellable)
                
            case .user(let action) :
                switch action {
                    case .start:
                        break
                    case .pause:
                        break
                    default:
                        break
                }
                
                //            case .start:
                //                publisher
                //                    .sink { [weak self] _ in
                //
                //                    }
                //                    .store(in: &cancellable)
                //            case .pause:
                //                cancellable = []
        }
    }
    
    private var shouldWork = false {didSet{
        //        update(shouldWork ? .start : .pause)
    }}
    
    private var refresh = false
    
    private func observe_detailViewVisible() {
        NotificationCenter.Publisher(center: .default, name: .detailViewVisible)
            .sink {
                let detailViewVisible = $0.userInfo!["detailViewVisible"] as! Bool
                let condition = detailViewVisible && self.bubble.state == .running
                self.shouldWork = condition ? true : false
            }
            .store(in: &detailViewVisibleCancellable)
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

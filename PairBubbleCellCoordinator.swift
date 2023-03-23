//
//  PairBubbleCellCoordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.02.2023.
//1 if cancellable is set to emty set, it will stop updating
//2 unowned because Coordinator must always have a bubble. If bubble gets deinit, Coordinator deinits as well
//5 if app is back onscreen it must refresh the PairBubbleCell [refresh = true]
//6 it shows if detailView is visible and bubble is running. ex: if bubble is not running and detailView viisble, it will return false. if bubble is running and detailView not visible it returns false. if bubble runs and detailview visible it returns true

import Combine
import Foundation
import UIKit

class PairBubbleCellCoordinator {
    weak private var bubble:Bubble? //2
    
    // MARK: - Public API
    func update(_ moment:Moment, _ shouldRefresh:Bool = false) {
        switch moment {
            case .automatic:
                if shouldWork {
                    publisher
                        .sink { [weak self] _ in self?.task() }
                        .store(in: &cancellable)
                }
                
            case .user(let action) :
                switch action {
                    case .start:
                        refresh = shouldRefresh ? true : false
                        publisher
                            .sink { [weak self] _ in self?.task() }
                            .store(in: &cancellable)
                        
                    case .pause, .deleteCurrentSession, .endSession:
                        cancellable = []
                        components = Components("0", "0", "0")
                        
                    case .reset:
                        cancellable = []
                        components = Components("0", "0", "0")
                        
                    case .deleteBubble:
                        cancellable = []
                        components = Components("0", "0", "0")
                        NotificationCenter.default.removeObserver(self, name: .detailViewVisible, object: bubble)
                }
        }
    }
    
    @Published private(set) var components = Components("0", "0", "0")
    
    // MARK: -
    private func task() {
        guard
            let bubble = bubble,
            let lastPairStart = bubble.lastPair?.start else { return }
        
        DispatchQueue.global().async {
            var Δ = Float(Date().timeIntervalSince(lastPairStart))
            
            Δ.round(.toNearestOrEven) //ex: 2346
                        
            let intValue = Int(Δ)
            let secValue = intValue%60
                        
            //send minute and hour
            if secValue == 0 || self.refresh {
                let giveMeAName = intValue/60%60
                let minValue = String(giveMeAName)
                
                DispatchQueue.main.async { self.components.min = minValue } //send Min
                
                if (giveMeAName%60) == 0 || self.refresh {
                    let hrValue = String(intValue/3600)
                    DispatchQueue.main.async { self.components.hr = hrValue } //send Hr
                }
            }
            
            DispatchQueue.main.async { //send Sec
                self.components.sec = String(secValue)
                self.refresh = false
            }
        }
    }
    
    private var initialValue:Float {
        guard let bubble = bubble else {
            fatalError()
        }
        if bubble.state == .running {
            let Δ = Date().timeIntervalSince(bubble.lastPair!.start!)
            let initialValue = Float(Δ)
            return initialValue
        } else {
            return 0
        }
    }
    
    private var shouldWork = false {didSet{
        if shouldWork {
            update(.automatic)
        } else {
            update(.user(.pause))
        }
    }} //6
    
    private var refresh = false
    
    private func observe_detailViewVisible() {
        NotificationCenter.Publisher(center: .default, name: .detailViewVisible)
            .sink { [weak self] notification in
                guard
                    let bubble = self?.bubble,
                    let self = self,
                    let detailViewVisible = notification.userInfo?["detailViewVisible"] as? Bool
                else { return }
                                
                let condition = detailViewVisible && bubble.state == .running
                self.shouldWork = condition ? true : false
                self.refresh = true
            }
            .store(in: &detailViewVisibleCancellable)
    }
    
    private func observe_AppActive() {
        let center = NotificationCenter.default
        center.addObserver(forName: .didBecomeActive, object: nil, queue: nil) { _ in
            self.refresh = true
        }
    } //5
    
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>() //1
    private var detailViewVisibleCancellable = Set<AnyCancellable>() //1
    
    // MARK: - Init Deinit
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
}

extension PairBubbleCellCoordinator {
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
        case deleteBubble
    }
    
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
}

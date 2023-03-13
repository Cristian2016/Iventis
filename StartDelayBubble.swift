//
//  StartDelayBubble+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//1 each time this published property is set, publisher emits and any view with a receiver on it, will receive the value. ex: SDButton.onReceive (sdb.coordinator.$currentClock) { currentClock in }
//2 should remove SDButton because state is ended
//3 elapsed since lastStart sdb.lastPair.start

import CoreData
import SwiftUI
import Combine
import MyPackage


public class StartDelayBubble: NSManagedObject {
    lazy var coordinator:Coordinator! = Coordinator(self)
}

extension StartDelayBubble {
    class Coordinator {
        private weak var sdb: StartDelayBubble?
        
        private lazy var initialClock = sdb?.initialClock ?? 0
        
        private func task(_ totalDuration:Float, _ lastStart:Date, _ currentClock:Float) { //bThread
                        
            let Δ = Float(Date().timeIntervalSince(lastStart)) //3
            let elapsedSinceFirstStart = totalDuration + Δ
            
            let viewModelShouldStartBubble = elapsedSinceFirstStart >= initialClock //2
            
            DispatchQueue.main.async {
                self.valueToDisplay = self.initialClock - elapsedSinceFirstStart
            }
            
            let difference = initialClock - elapsedSinceFirstStart
            
            if (Float(0)...1).contains(difference) {
                let deadline:DispatchTime = .now() + DispatchTimeInterval.milliseconds(Int(difference * 1000))
                precisionTimer.setHandler(with: deadline) { [weak self] in
                    self?.startBubble(self?.initialClock)
                }
            } else {
                if viewModelShouldStartBubble { startBubble(elapsedSinceFirstStart) }
            }
        }
        
        func update(_ moment:Moment) { //main Thread
            
            guard let lastStart = sdb?.pairs_.last?.start else { return }
            let totalDuration = sdb!.totalDuration
            let currentClock = sdb!.currentClock
                        
            switch moment {
                case .automatic: //when app lanches
                    self.publisher
                        .sink { [weak self] _ in self?.task(totalDuration, lastStart, currentClock) }
                        .store(in: &self.cancellable) //connect
                    
                case .user(let action) :
                    switch action {
                        case .start:
                            publisher
                                .sink { [weak self] _ in
                                    self?.task(totalDuration, lastStart, currentClock)
                                }
                                .store(in: &cancellable)
                            
                        case .pause:
                            cancellable = []
                            valueToDisplay = sdb!.currentClock
                            
                        case .reset: //sdb.currentClock has reached zero
                            cancellable = []
                            //remove all pairs
                            
                    }
            }
        }
        
        @Published var valueToDisplay:Float //1
        @Published var animateSDButton = false
        
        private lazy var publisher =
        NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
        
        private(set) var cancellable = Set<AnyCancellable>()
        
        private func observeActivePhase() {
            let center = NotificationCenter.default
            center.addObserver(forName: .didBecomeActive, object: nil, queue: nil) {
                [weak self] _ in
            }
        }
        
        private var precisionTimer = PrecisionTimer()
        
        private func startBubble(_ elapsedSinceFirstStart: Float?) {
            //compute startCorrection
            //notify viewModel currentClock has reached zero, send startCorrection ->
            //-> viewModel removes SDButton
            //-> viewModel starts bubble [toggleBubbleStart] with startCorrection
            
            guard let elapsedSinceFirstStart = elapsedSinceFirstStart else { return }
            
            let startCorrection = TimeInterval(elapsedSinceFirstStart - initialClock)
            
            DispatchQueue.main.async {
                let info:[String : Any] = ["rank" : self.sdb!.bubble!.rank,
                                           "startCorrection" : startCorrection]
                
                NotificationCenter.default.post(name: .killSDB, object: nil, userInfo: info)
                
                self.cancellable = []
                self.sdb!.currentClock = 0 //only to set sdb.state to .finished
            }
        }
        
        // MARK: - Init Deinit
        init(_ sdb:StartDelayBubble) {
            self.sdb = sdb
            self.valueToDisplay = sdb.currentClock
            observeActivePhase()
            
            if sdb.state == .running { update(.automatic) }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            print(#function, " SDBCoordinator")
        }
    }
    
    enum State {
        case brandNew
        case running
        case paused
        case finished
    }
    
    var state: State {
        if pairs_.isEmpty { return .brandNew }
        else {
            if currentClock == 0 { return .finished }
            let lastPair = pairs_.last!
            return lastPair.pause != nil ? .paused : .running
        }
    }
    
    var pairs_:[SDBPair] {
        get { pairs?.array as? [SDBPair] ?? [] }
        set { pairs = NSOrderedSet(array: newValue) }
    }
    
    enum Moment {
        case user(Action)
        case automatic
    }
    
    enum Action {
        case start
        case pause
        case reset
    }
}

//
//  StartDelayBubble+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//1 each time this published property is set, publisher emits and any view with a receiver on it, will receive the value. ex: SDButton.onReceive (sdb.coordinator.$currentClock) { currentClock in }
//2 should remove SDButton because state is ended

import CoreData
import SwiftUI
import Combine


public class StartDelayBubble: NSManagedObject {
    lazy var coordinator:Coordinator! = Coordinator(self)
}

extension StartDelayBubble {
    class Coordinator {
        private weak var sdb: StartDelayBubble?
        
        private func task(_ totalDuration:Float, _ lastStart:Date, _ initialClock:Float) { //bThread
            
            let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart))
            let elapsedSinceFirstStart = totalDuration + elapsedSinceLastStart
            
            let viewModelShouldStartBubble = elapsedSinceFirstStart >= initialClock //2
            
            if viewModelShouldStartBubble {
                print(elapsedSinceFirstStart, initialClock, elapsedSinceLastStart >= initialClock)
                //notify viewModel that currentClock has reached zero ->
                //-> viewModel will remove SDB
                //-> viewModel starts bubble [toggleBubbleStart]
                cancellable = []
            }
        }
        
        func update(_ moment:Moment) { //main Thread
            
            let lastStart = sdb!.pairs_.last!.start
            let totalDuration = sdb!.totalDuration
            let initialClock = sdb!.initialClock
            
            switch moment {
                case .automatic: //when app lanches
                    self.publisher
                        .sink { [weak self] _ in self?.task(totalDuration, lastStart, initialClock) }
                        .store(in: &self.cancellable) //connect
                    
                case .user(let action) :
                    switch action {
                        case .start:
                            publisher
                                .sink { [weak self] _ in self?.task(totalDuration, lastStart, initialClock) }
                                .store(in: &cancellable)
                            
                        case .pause:
                            cancellable = []
                            valueToDisplay = sdb!.currentClock
                            print("totalDuration at pause \(sdb!.totalDuration)")
                            
                        case .reset: //sdb.currentClock has reached zero
                            cancellable = []
                    }
            }
        }
        
        @Published private(set) var valueToDisplay:Float //1
        
        private lazy var publisher =
        NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
        
        private var cancellable = Set<AnyCancellable>()
        
        private func observeActivePhase() {
            let center = NotificationCenter.default
            center.addObserver(forName: .didBecomeActive, object: nil, queue: nil) {
                [weak self] _ in
            }
        }
        
        // MARK: - Init Deinit
        init(_ sdb:StartDelayBubble) {
            self.sdb = sdb
            self.valueToDisplay = sdb.currentClock
            observeActivePhase()
            
            if sdb.state == .running { update(.automatic) }
        }
        
        deinit { NotificationCenter.default.removeObserver(self) }
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
            if currentClock <= 0 { return .finished }
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

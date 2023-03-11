//
//  StartDelayBubble+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//

import CoreData
import SwiftUI
import Combine


public class StartDelayBubble: NSManagedObject {
    lazy var coordinator:Coordinator! = Coordinator(self)
}

extension StartDelayBubble {
    class Coordinator {
        private weak var sdb: StartDelayBubble?
        
        private func task() { print(#function)
            
        }
        
        func update(_ moment:Moment) {
            switch moment {
                case .automatic: break
                case .user(let action) :
                    switch action {
                        case .start:
                            publisher
                                .sink { [weak self] _ in self?.task() }
                                .store(in: &cancellable)
        
                        case .pause:
                            cancellable = []
                            
                        case .reset:
                            cancellable = []
                    }
            }
        }
        
        @Published private(set) var currentClock:Float
        
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
            self.currentClock = sdb.currentClock
            observeActivePhase()
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

//
//  PairBubbleCellCoordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.02.2023.
//1 if cancellable is set to emty set, it will stop updating

import Combine
import Foundation

class PairBubbleCellCoordinator {
    unowned private let bubble:Bubble
    
    @Published private(set) var components = Components("-1", "-1", "-1")
    
    init(bubble: Bubble) {
        self.bubble = bubble
    }
    
    deinit {
        "PairBubbleCellCoordinator deinit"
    }
    
    private func update(_ action:Action) {
        switch action {
            case .start:
                publisher
                    .sink { [weak self] _ in
                        print("signal received")
                    }
                    .store(in: &cancellable)
            case .pause:
                cancellable = []
        }
    }
    
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>() //1
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
    
    enum Action {
        case start
        case pause
    }
}

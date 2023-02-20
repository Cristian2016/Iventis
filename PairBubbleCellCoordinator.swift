//
//  PairBubbleCellCoordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.02.2023.
//1 if cancellable is set to emty set, it will stop updating

import Combine

class PairBubbleCellCoordinator {
    unowned private let bubble:Bubble
    
    @Published private(set) var components = Components("-1", "-1", "-1")
    
    init(bubble: Bubble) {
        self.bubble = bubble
    }
    
    private func update(_ action:Action) {
        
    }
    
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

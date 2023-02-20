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
        if bubble.state == .running {
            
        }
    }
    
    deinit {
        print("PairBubbleCellCoordinator deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func update(_ action:Action) {
        switch action {
            case .start:
                if !detailVisible { return }
                publisher
                    .sink { [weak self] _ in
                        print("PairBubbleCellCoordinator signal received")
                    }
                    .store(in: &cancellable)
            case .pause:
                cancellable = []
        }
    }
    
    private var detailVisible = false
    var isBubbleRunning = false
    
    private func observe_detailViewVisible() {
        NotificationCenter.Publisher(center: .default, name: .detailViewVisible)
            .sink {
                self.detailVisible = $0.userInfo!["detailViewVisible"] as! Bool
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
    
    enum Action {
        case start
        case pause
    }
}

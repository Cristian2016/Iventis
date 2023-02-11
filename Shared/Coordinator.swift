//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//

import SwiftUI
import Combine

class BubbleCellCoordinator {
    // MARK: - Publishers
    //they emit their initial value, without .send()! ⚠️
    var visibility:CurrentValueSubject<Show, Never> = .init(.none)
    
    var color:CurrentValueSubject<Color, Never> = .init(.blue)
    
    lazy var timePublisher:CurrentValueSubject<Int, Never> = .init(Int(bubble.currentClock))
    
    // MARK: -
    private var show = Show.none
    let bubble:Bubble
    
    init(for bubble:Bubble) {
        self.bubble = bubble
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    ///on wake-up it starts observing backgroundTimer
    func wakeUp() {
        NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
            .sink { [weak self] _ in
                
                if self?.bubble.state != .running { return }
                
//                print("signal for \(self.bubble.color!)")
                DispatchQueue.main.async {
                    self?.timePublisher.value += 1
                    if self?.timePublisher.value == 5 {
                        self?.visibility.send(.min(true))
                    }
                    if self?.timePublisher.value == 10 {
                        self?.visibility.send(.hr(true))
                        
                    }
                }
            }
            .store(in: &cancellable)
    }
}

extension BubbleCellCoordinator {
    enum Show {
        case min(Bool)
        case hr(Bool)
        case none
    }
}

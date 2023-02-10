//
//  ThreeCircles.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
// it shows bubble.color and shows or hide minutes and hours bubble. that's it!

import SwiftUI
import Combine
import MyPackage

struct ThreeCircles: View {
    
    let bubble:Bubble
    private let spacing = CGFloat(-40)
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
    }
    
    @State private var color:Color
    
    @State private var showMin = false
    @State private var showHr = false
    
    var body: some View {
            HStack(spacing: spacing) {
                circle(.hr)
                circle(.min)
                circle(.sec)
            }
            .onReceive(bubble.coordinator.visibility) {
            switch $0 {
                case .none: break
                case .min(let show):
                    withAnimation(animation) { showMin = show }
                case .hr(let show):
                    withAnimation(animation) { showHr = show }
            }
        }
            .onReceive(bubble.coordinator.color) { color = $0 }
    }
    
    // MARK: -
    private let animation = Animation.spring(response: 0.5, dampingFraction: 0.6)
    
    // MARK: - Lego
    @ViewBuilder
    private func circle(_ kind:Kind) -> some View {
        switch kind {
            case .hr:
                Circle()
                    .fill(color)
                    .scaleEffect(showHr ? 1 : 0)
            case .min:
                Circle()
                    .fill(color)
                    .scaleEffect(showMin ? 1 : 0)
            case .sec:
                Circle()
                    .fill(color)
        }
    }
    
    // MARK: -
    enum Kind {
        case sec
        case min
        case hr
    }
}

class BubbleCellCoordinator {
    //they emit their initial value, without .send()! ⚠️
    var visibility:CurrentValueSubject<Show, Never> = .init(.none)
    var color:CurrentValueSubject<Color, Never> = .init(.blue)
    
    private var show = Show.none
    let bubble:Bubble
    
    enum Show {
        case min(Bool)
        case hr(Bool)
        case none
    }
    
    init(for bubble:Bubble) {
        print(#function, "BubbleCellCoordinator \(bubble.color!)")
        self.bubble = bubble
    }
    
    ///on wake-up it starts observing backgroundTimer
    func wakeUp() {
        addObserver()
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    private func addObserver() {
        NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
            .sink { notification in
                print("signal received")
            }
            .store(in: &cancellable)
    }
}


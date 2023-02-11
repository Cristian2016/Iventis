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
    private let spacing:CGFloat
    
    init(_ bubble:Bubble, _ spacing:CGFloat) {
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
        self.spacing = spacing
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
                    .scaleEffect(showHr ? 1 : 0.01)
            case .min:
                Circle()
                    .fill(color)
                    .scaleEffect(showMin ? 1 : 0.01)
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

struct ThreeLabels: View {
    let bubble:Bubble
    
    @State private var time = String()
    
    var body: some View {
        Text(time)
            .onReceive(bubble.coordinator.timeComponentsPublisher) { output in
                time = String(output)
            }
    }
}

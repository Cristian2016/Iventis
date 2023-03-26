//
//  SecondsLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//

import SwiftUI

struct SecondsLabel: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
        
    @State private var sec:String
    
    var body: some View {
        if bubble.coordinator != nil {
            clearCircle
                .overlay (
                    clearRectangle
                        .aspectRatio(1.2, contentMode: .fit)
                        .overlay (text)
                )
                .overlay(content: {
                    VStack {
                        Color.clear
                            .aspectRatio(6, contentMode: .fit)
                            .overlay { TimerProgressView(bubble) }
                        Color.clear
                        Color.clear
                    }
                    .scaleEffect(x: 1.4, y: 1.4)
                })
                .onReceive(bubble.coordinator.$components) { sec = $0.sec }
        }
    }
    
    // MARK: - Lego
    private var clearCircle: some View {
        Circle().fill(Color.clear)
    }
    
    private var clearRectangle:some View {
        Rectangle().fill(.clear)
    }
    
    private var text:some View {
        Text(sec).allowsHitTesting(false)
            .font(.system(size: 400))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
    }
    
    // MARK: - Init
    init?(bubble: Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
        self.sec = bubble.coordinator.components.sec
    }
}

extension SecondsLabel {
    struct TimerProgressView:View {
        private let precision = "%.2f"
        private let bubble:Bubble
        @State private var progress = "1.0"
        
        var body: some View {
            ZStack {
                if bubble.isTimer {
                    Text(progress)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.1)
                        .padding([.leading, .trailing], 10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
                        .onReceive(bubble.coordinator.$timerProgress) {
                            progress = String(format: precision, $0)
                        }
                        .environment(\.colorScheme, .light)
                }
            }
        }
        
        init(_ bubble: Bubble) { self.bubble = bubble }
    }
}

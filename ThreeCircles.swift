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
    let metrics:BubbleCell.Metrics
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var minOpacity = CGFloat(1)
    @State private var hrOpacity = CGFloat(1)
    @State private var color:Color
    
    init(bubble: Bubble, metrics: BubbleCell.Metrics) {
        self.bubble = bubble
        self.metrics = metrics
        self.color = Color.bubbleColor(forName: bubble.color)
    }
    
    var body: some View {
        Rectangle().fill(.clear)
            .aspectRatio(metrics.ratio, contentMode: .fit)
            .overlay {
                HStack {
                    /* Hr */ colorCircle
                        .opacity(hrOpacity)
                        .onTapGesture { toggleBubbleDetail() }
                        .onLongPressGesture { showNotesList() }
                    /* Min */ colorCircle
                        .opacity(minOpacity)
                        .onTapGesture { toggleBubbleDetail() }
                        .onLongPressGesture { showNotesList() }
                    /* Sec */ SecondsCircle(bubble: bubble, color: color, scale: metrics.circleScale)
                }
                .scaleEffect(x: metrics.hstackScale, y: metrics.hstackScale)
                .onReceive(bubble.coordinator.$timeComponentsOpacity) { output in
                    minOpacity = output.min
                    hrOpacity = output.hr
                }
                .onReceive(bubble.coordinator.color) { color = $0 }
            }
    }
    
    // MARK: - User Intents
    private func toggleBubbleDetail() {
        viewModel.path = viewModel.path.isEmpty ? [bubble] : []
    }
    
    func showNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.notesForBubble.send(bubble)
    }
}

extension ThreeCircles {
    ///either circle or square. Square means bubble has a widget
    enum BubbleShape {
        case circle
        case square
    }
    
    ///either a circle or a square
    @ViewBuilder
    private var bubbleShape: some View {
        if bubble.hasWidget { RoundedRectangle(cornerRadius: 20).fill(color) }
        else { Circle().fill(color) }
    }
    
    private var colorCircle:some View {
        Circle()
            .fill(color)
            .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
    }
}


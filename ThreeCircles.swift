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
    
    @State private var minOpacity = CGFloat(0)
    @State private var hrOpacity = CGFloat(0)
    
    var body: some View {
        if !bubble.isFault {
            HStack (spacing: metrics.spacing) {
                /* Hr */ bubbleShape.opacity(hrOpacity)
                /* Min */ bubbleShape.opacity(minOpacity)
                /* Sec */ bubbleShape
            }
            .onReceive(bubble.coordinator.opacityPublisher) { output in
                if output.count == 1 {
                    switch output[0] {
                        case .min(let value): minOpacity = (value == .show) ? 1 : 0
                        case .hr(let value): hrOpacity = (value == .show) ? 1 : 0
                    }
                } else {
                    switch output[0] {
                        case .min(let value): minOpacity = (value == .show) ? 1 : 0
                        default: break
                    }
                    
                    switch output[1] {
                        case .hr(let value): hrOpacity = (value == .show) ? 1 : 0
                        default: break
                    }
                }
            }
        }
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
        if bubble.hasWidget {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bubbleColor(forName: bubble.color))
        } else {
            Circle()
                .fill(Color.bubbleColor(forName: bubble.color))
        }
    }
}

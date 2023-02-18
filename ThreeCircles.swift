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
    
    let circleScale = CGFloat(1.8)
    let hstackScale = CGFloat(0.833)
    let ratio = CGFloat(2.05)
    
    @State private var minOpacity = CGFloat(0)
    @State private var hrOpacity = CGFloat(0)
    @State private var color:Color
    
    init(bubble: Bubble, metrics: BubbleCell.Metrics) {
        self.bubble = bubble
        self.metrics = metrics
        self.color = Color.bubbleColor(forName: bubble.color)
    }
    
    var body: some View {
        if !bubble.isFault {
            Rectangle().fill(.clear)
                .aspectRatio(ratio, contentMode: .fit)
                .overlay {
                    HStack {
                        /* Hr */ colorCircle
                            .opacity(hrOpacity)
                        /* Min */ colorCircle
                            .opacity(minOpacity)
                        /* Sec */ SecondsCircle(bubble: bubble, color: color, scale: circleScale)
                    }
                    .scaleEffect(x: hstackScale, y: hstackScale)
                    .onReceive(bubble.coordinator.$opacity) {
                        minOpacity = $0.min
                        hrOpacity = $0.hr
                    }
                    .onReceive(bubble.coordinator.colorPublisher) { color = $0 }
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
                .fill(color)
        } else {
            Circle()
                .fill(color)
        }
    }
    
    private var colorCircle:some View {
        Circle()
            .fill(color)
            .scaleEffect(x: circleScale, y: circleScale)
    }
}

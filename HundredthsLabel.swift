//
//  HundredthsCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
//

import SwiftUI

struct HundredthsLabel: View {
    var bubble:Bubble
    let scale = CGFloat(0.35)
    
    var body: some View {
        Circle()
            .fill(Color.pauseStickerColor)
            .overlay {
                Rectangle().fill(.clear)
                    .aspectRatio(2.0, contentMode: .fit) //smaller ratio is bigger font
                    .overlay { label }
            }
            .foregroundStyle(.background)
            .allowsHitTesting(false)
        //properties that will be animated
            .opacity(isBubbleRunning ? 0 : 1)
            .offset(x: isBubbleRunning ? -20 : 0, y: isBubbleRunning ? -20 : 0)
            .scaleEffect(isBubbleRunning ? 0.7 : scale, anchor: .bottomTrailing )
            .zIndex(isBubbleRunning ? -1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isBubbleRunning)
    }
    
    private var isBubbleRunning:Bool { bubble.state == .running }
    
    private var label:some View {
        let hundredths = bubble.coordinator.timeComponents.hundredths
        let text = bubble.state != .finished ? hundredths : "✖︎"
        
        return Text(text).modifier(HundredthsStyle())
    }
    
    struct HundredthsStyle:ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 200))
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
        }
    }
}

//
//  HundredthsCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
//

import SwiftUI

struct HundredthsCircle: View {
    let bubble:Bubble
    @State private var hundredths:String
    let scale = CGFloat(0.35)
    
    var body: some View {
        Circle()
            .fill(Color.pauseStickerColor)
            .adaptiveText(hundredths, true)
            .foregroundColor(.background)
            .allowsHitTesting(false)
            .onReceive(bubble.coordinator.$components) { hundredths = $0.hundredths }
        //properties that will be animated
            .opacity(isBubbleRunning ? 0 : 1)
            .offset(x: isBubbleRunning ? -20 : 0, y: isBubbleRunning ? -20 : 0)
            .scaleEffect(!isBubbleRunning ? scale : 0.7, anchor: .bottomTrailing )
            .zIndex(isBubbleRunning ? -1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isBubbleRunning)
    }
    
    init(bubble: Bubble) {
        self.bubble = bubble
        
        let components = bubble.coordinator.components
        self.hundredths = components.hundredths
    }
    
    private var isBubbleRunning:Bool { bubble.state == .running }
}

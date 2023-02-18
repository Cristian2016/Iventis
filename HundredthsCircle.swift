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
    
    var body: some View {
        Circle()
            .fill(Color.pauseStickerColor)
            .adaptiveText(hundredths, true)
            .foregroundColor(.black)
            .allowsHitTesting(false)
            .scaleEffect(x: 0.34, y: 0.34, anchor: .bottomTrailing)
            .onReceive(bubble.coordinator.$components) { hundredths = $0.hundredths }
    }
    
    init(bubble: Bubble) {
        self.bubble = bubble
        
        let components = bubble.coordinator.components
        self.hundredths = components.hundredths
    }
}

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
        let show = bubble.coordinator.showHundredths
        
        Circle()
            .fill(Color.pauseStickerColor)
            .overlay {
                Rectangle().fill(.clear)
                    .aspectRatio(2.0, contentMode: .fit) //smaller ratio is bigger font
                    .overlay { label }
            }
            .foregroundStyle(Color.background)
            .allowsHitTesting(false)
        //properties that will be animated
            .offset(x: show ? 0.0 : -20, y: show ? 0.0 : -20)
            .scaleEffect(show ? scale : 0.7, anchor: .bottomTrailing )
            .zIndex(show ? 0 : -1)
            .animation(.spring(response: 0.2, dampingFraction: 0.4), value: show)
            .allowsHitTesting(false)
            .opacity(show ? 1.0 : 0.005)
    }
        
    private var label:some View {
        let hundredths = bubble.coordinator.components.hundredths
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

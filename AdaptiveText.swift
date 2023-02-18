//
//  AdaptiveText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
// .overlay { if !isBubbleRunning { hundredthsView }}

import SwiftUI

struct AdaptiveText: ViewModifier {
    let text:String
    var maxFontSize:CGFloat
    var show:Bool
    
    func body(content: Content) -> some View {
        if show {
            content //seconds circle ex
                .overlay {
                    Rectangle().fill(.clear)
                        .aspectRatio(2.1, contentMode: .fit)
                        .overlay {
                            Text(text)
                                .font(.system(size: maxFontSize))
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }
                }
        }
    }
    
//    private var hundredthsView:some View {
//        Push(.bottomRight) {
//            Text(hundredths)
//                .padding()
//                .background(Circle().foregroundColor(.pauseStickerColor))
//                .foregroundColor(.pauseStickerFontColor)
//                .font(.system(size: hundredthsFontSize, weight: .semibold, design: .rounded))
//                .scaleEffect(isSecondsTapped && !isBubbleRunning ? 2 : 1.0)
//                .offset(x: isSecondsTapped && !isBubbleRunning ? -20 : 0,
//                        y: isSecondsTapped && !isBubbleRunning ? -20 : 0)
//                .opacity(isSecondsTapped && !isBubbleRunning ? 0 : 1)
//                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
//                .zIndex(1)
//                .onTapGesture { userTappedHundredths() }
//                .onReceive(bubble.coordinator.$components) { hundredths = $0.hundredths }
//        }
//    }
}

extension View {
    func adaptiveText(_ text:String, maxSize:CGFloat = 200, _ show:Bool) -> some View {
        self.modifier(AdaptiveText(text: text, maxFontSize: maxSize, show: show))
    }
}

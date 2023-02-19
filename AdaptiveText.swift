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
}

extension View {
    func adaptiveText(_ text:String, maxSize:CGFloat = 200, _ show:Bool) -> some View {
        self.modifier(AdaptiveText(text: text, maxFontSize: maxSize, show: show))
    }
}

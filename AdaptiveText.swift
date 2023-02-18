//
//  AdaptiveText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
//

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
                        .aspectRatio(1.2, contentMode: .fit)
                        .overlay {
                            Text(text)
                                .font(.system(size: maxFontSize))
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

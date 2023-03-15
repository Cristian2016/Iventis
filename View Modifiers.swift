//
//  AdaptiveText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
// .overlay { if !isBubbleRunning { hundredthsView }}
//1 https://www.avanderlee.com/swiftui/disable-animations-transactions/

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

struct PairCountModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.gray)
            .font(.system(size: 16))
            .fontWeight(.medium)
    }
}

struct DisableAnimation:ViewModifier { //1
    func body(content: Content) -> some View {
        content
            .transaction {
                $0.disablesAnimations = true
            }
    }
}

extension View {
    func adaptiveText(_ text:String, maxSize:CGFloat = 200, _ show:Bool) -> some View {
        self.modifier(AdaptiveText(text: text, maxFontSize: maxSize, show: show))
    }
    
    func pairCountModifier() -> some View {
        modifier(PairCountModifier())
    }
    
    ///it doesn't allow animations on that view, puta!
    func animationDisabled() -> some View {
        modifier(DisableAnimation())
    }
}

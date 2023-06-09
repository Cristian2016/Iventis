//
//  TestDelete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//1 if tappedColor [chosen color] is not the same as currentColor [curent bubble color, before changing the color]

import SwiftUI

struct ColorsGrid: View {
    @EnvironmentObject private var viewModel:ViewModel
    private let bubble:Bubble
    
    private let dismissAction:() -> ()
    private let metrics = Metrics()
    
    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            ForEach(Color.paletteTriColors, id:\.self) { tricolors in
                GridRow {
                    ForEach(tricolors) { tricolor in
                        let sameColor = (tricolor.description == bubble.color)
                        
                        tricolor.sec
                            .overlay { if sameColor { checkmark }}
                            .onTapGesture {
                                if !sameColor { //1
                                    viewModel.changeColor(of: bubble, to: tricolor.description)
                                    dismissAction()
                                }
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Lego
    private var checkmark:some View {
        Image(systemName: "checkmark")
            .foregroundColor(.white)
            .font(metrics.checkmarkFont)
    }
    
//    private var colorNameView:some View {
//        let title = Color.userFriendlyBubbleColorName(for: bubble.color)
//        let color = Color.bubbleColor(forName: bubble.color)
//        return FusedLabel(content: .init(title: title, symbol: "paintpalette.fill", size: .small, color: color, isFilled: true))
//    }
    
    // MARK: -
    init(_ bubble:Bubble, _ dismissAction: @escaping () -> Void) {
        self.bubble = bubble
        self.dismissAction = dismissAction
    }
    
    // MARK: -
    struct Metrics {
        let checkmarkFont = Font.system(size: 30, weight: .semibold)
    }
}

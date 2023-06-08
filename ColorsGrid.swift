//
//  TestDelete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//1 if tappedColor [chosen color] is not the same as currentColor [curent bubble color, before changing the color]

import SwiftUI

struct ColorsGrid: View {
    @EnvironmentObject private var viewModel:ViewModel
    private let columns:[GridItem]
    private let metrics = Metrics()
    private let dismissAction:() -> ()
    private let bubble:Bubble
    
    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            ForEach(Color.paletteTriColors, id: \.self) { tricolors in                           GridRow {
                    ForEach(tricolors) { tricolor in
                    let sameColor = tricolor.description == bubble.color
                    
                    tricolor.sec
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
    
    private var colorNameView:some View {
        Text(Color.userFriendlyBubbleColorName(for: bubble.color))
            .padding([.leading, .trailing])
            .background(Color.bubbleColor(forName: bubble.color), in: RoundedRectangle(cornerRadius: 4))
            .foregroundColor(.white)
            .font(metrics.checkmarkFont)
    }
    
    // MARK: -
    init(_ bubble:Bubble, _ dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
        self.columns = Array(repeating: GridItem(spacing: 1), count: 3)
        self.bubble = bubble
    }
    
    // MARK: -
    struct Metrics {
        let checkmarkFont = Font.system(size: 30, weight: .semibold)
    }
}

//struct ColorsGrid_Previews: PreviewProvider {
//    static let bubble:Bubble = {
//        let bubble = Bubble(context: PersistenceController.preview.viewContext)
//        let sdb = StartDelayBubble(context: PersistenceController.preview.viewContext)
//        sdb.referenceDelay = 0
//
//        bubble.color = "darkGreen"
//        return bubble
//    }()
//    static var previews: some View {
//        ColorsGrid(bubble, spacing: 0) {  }
//    }
//}

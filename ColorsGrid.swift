//
//  TestDelete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI

struct ColorsGrid: View {
    @EnvironmentObject private var viewModel:ViewModel
    private let columns:[GridItem]
    private let metrics:Metrics
    private let dismissAction:() -> ()
    private let bubble:Bubble
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns, spacing: metrics.spacing) {
                    let height = itemHeight(geo)
                    
                    ForEach(Color.triColors) { tricolor in
                        tricolor.sec
                            .frame(height: height)
                            .overlay {
                                if tricolor.description == bubble.color {
                                    checkmark
                                }
                            }
                            .onTapGesture {
                                if tricolor.description != bubble.color {
                                    viewModel.changeColor(of: bubble, to: tricolor.description)
                                    dismissAction()
                                }
                            }
                    }
                }
                .background(.white)
            }
            .background {
                VStack {
                    colorNameView
                    Spacer()
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
    init(_ bubble:Bubble, spacing: CGFloat, _ dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
        self.columns = Array(repeating: GridItem(spacing: spacing), count: 3)
        self.metrics = Metrics(spacing: spacing)
        self.bubble = bubble
    }
    
    // MARK: -
    func itemHeight(_ geo:GeometryProxy) -> CGFloat {
        let itemCount = Color.triColors.count
        let totalSpacingToSubstract = itemCount/columns.count - 1
        
        return (geo.size.height - metrics.spacing * CGFloat(totalSpacingToSubstract)) / CGFloat(itemCount / columns.count)
    }
    
    struct Metrics {
        let spacing:CGFloat
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

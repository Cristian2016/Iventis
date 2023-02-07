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
                            .onTapGesture {
                                viewModel.saveColor(for: bubble, to: tricolor.description)
                                dismissAction()
                            }
                    }
                }
            }
        }
    }
    
    init(_ bubble:Bubble, spacing: CGFloat, _ dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
        self.columns = Array(repeating: GridItem(spacing: spacing), count: 3)
        self.metrics = Metrics(spacing: spacing)
        self.bubble = bubble
    }
    
    func itemHeight(_ geo:GeometryProxy) -> CGFloat {
        let itemCount = Color.triColors.count
        let totalSpacingToSubstract = itemCount/columns.count - 1
        
        return (geo.size.height - metrics.spacing * CGFloat(totalSpacingToSubstract)) / CGFloat(itemCount / columns.count)
    }
    
    struct Metrics {
        let spacing:CGFloat
    }
}

struct ColorsGrid_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        let sdb = StartDelayBubble(context: PersistenceController.preview.viewContext)
        sdb.referenceDelay = 0
        
        bubble.sdb = sdb
        bubble.color = "darkGreen"
        return bubble
    }()
    static var previews: some View {
        ColorsGrid(bubble, spacing: 0) {  }
    }
}

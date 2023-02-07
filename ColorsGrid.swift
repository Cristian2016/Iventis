//
//  TestDelete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI

struct ColorsGrid: View {
    let columns:[GridItem]
    let metrics:Metrics
    let tapAction:() -> ()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns, spacing: metrics.spacing) {
                    let height = itemHeight(geo)
                    
                    ForEach(Color.triColors) { tricolor in
                        tricolor.sec
                            .frame(height: height)
                            .onTapGesture { self.tapAction() }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    init(spacing: CGFloat, _ tapAction: @escaping () -> Void) {
        self.tapAction = tapAction
        self.columns = Array(repeating: GridItem(spacing: spacing), count: 3)
        self.metrics = Metrics(spacing: spacing)
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
    static var previews: some View {
        ColorsGrid(spacing: 10) { }
    }
}

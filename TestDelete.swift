//
//  TestDelete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI

struct TestDelete: View {
    let metrics = Metrics()
    
    struct Metrics {
        let spacing = CGFloat(4)
    }
    
    func height(_ geo:GeometryProxy) -> CGFloat {
        let itemCount = Color.triColors.count
        let totalSpacingToSubstract = itemCount/columns.count - 1
        
        return (geo.size.height - metrics.spacing * CGFloat(totalSpacingToSubstract)) / CGFloat(itemCount / columns.count)
    }
    
    let columns = Array(repeating: GridItem(spacing: 4), count: 3)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns, spacing: metrics.spacing) {
                    let height = height(geo)
                    ForEach(Color.triColors) { tricolor in
                        tricolor.sec
                            .frame(height: height)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct TestDelete_Previews: PreviewProvider {
    static var previews: some View {
        TestDelete()
    }
}

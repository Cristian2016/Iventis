//
//  TestDelete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI

struct TestDelete: View {
    @State private var size = CGSize.zero
    let metrics = Metrics()
    
    struct Metrics {
        let spacing = CGFloat(4)
    }
    
    func height(_ geo:GeometryProxy) -> CGFloat {
        let totalSpacingToSubstract = Color.triColors.count/columns.count - 1
        return (geo.size.height - metrics.spacing * CGFloat(totalSpacingToSubstract)) / CGFloat(Color.triColors.count / columns.count)
    }
    
    let columns = Array(repeating: GridItem(spacing: 4), count: 3)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: metrics.spacing) {
                        let height = height(geo)
                        ForEach(Color.triColors) { tricolor in
                            tricolor.sec
                                .frame(height: height)
                        }
                    }
                }
                .background { Color.yellow }
                
                Text("\(size.height)")
            }
            .onAppear { size = geo.size }
        }
        .ignoresSafeArea()
    }
}

struct TestDelete_Previews: PreviewProvider {
    static var previews: some View {
        TestDelete()
    }
}

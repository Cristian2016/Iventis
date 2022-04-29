//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
    @Binding var showDetail:Bool
    init(_ showDetail:Binding<Bool>) {
        _showDetail = .init(projectedValue: showDetail)
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            Color.blue
            VStack {
                Text("Bubble Detail")
                Text("Dismiss")
                    .onTapGesture {
                        showDetail = false
                    }
            }
        }
        .opacity(showDetail ? 1 : 0)
        .ignoresSafeArea()
    }
}

struct BubbleDetail_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(.constant(false))
    }
}

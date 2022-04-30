//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
    @Binding var showDetailView:Bool
    
    // MARK: -
    var body: some View {
        ZStack {
            Color.detailViewBackground
            VStack {
                Text("Bubble Detail")
            }
        }
        .ignoresSafeArea()
    }
}

struct BubbleDetail_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(showDetailView: .constant(true))
    }
}

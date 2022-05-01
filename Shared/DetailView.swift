//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
    @Binding var showDetailView:Bool
    var cellHeight:CGFloat
    
    // MARK: -
    var body: some View {
        ZStack {
            VStack {
                Spacer(minLength: 330)
                Color.detailViewBackground
            }
            Text("Detail")
        }
        .ignoresSafeArea()
    }
}

struct BubbleDetail_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(showDetailView: .constant(true), cellHeight: 300)
    }
}

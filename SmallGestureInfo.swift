//
//  SmallGestureInfo.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 09.06.2023.
//

import SwiftUI

struct SmallGestureInfo: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Label("Clear", systemImage: "xmark.square.fill")
                .labelStyle(MyLabelStyle(alignedRight: false, color: .red))
            Label("Swipe", systemImage: "arrow.backward.circle.fill")
                .labelStyle(MyLabelStyle())
        }
    }
}

struct SmallGestureInfo_Previews: PreviewProvider {
    static var previews: some View {
        SmallGestureInfo()
    }
}

struct MyLabelStyle:LabelStyle {
    var alignedRight = true
    var color = Color.label
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: alignedRight ? .leading : .trailing) {
            configuration.icon
            configuration.title
                .font(.system(size: 10))
        }
        .foregroundColor(color)
    }
}

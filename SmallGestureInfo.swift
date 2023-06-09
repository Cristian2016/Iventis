//
//  SmallGestureInfo.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 09.06.2023.
//

import SwiftUI

struct SmallGestureInfo: View {
    @State private var showText = true
    
    var body: some View {
        HStack(alignment: .bottom) {
            Label("Clear", systemImage: "xmark.square.fill")
                .labelStyle(MyLabelStyle(alignedRight: false, color: .red, showText: showText))
            Label("Swipe", systemImage: "arrow.backward.circle.fill")
                .labelStyle(MyLabelStyle(showText: showText))
        }
        .onTapGesture {
            withAnimation {
                showText = !showText
            }
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
    var showText = true
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: alignedRight ? .leading : .trailing) {
            configuration.icon
            if showText {
                configuration.title
                    .font(.system(size: 10))
            }
        }
        .foregroundColor(color)
    }
}

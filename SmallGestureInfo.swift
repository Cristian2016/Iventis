//
//  SmallGestureInfo.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 09.06.2023.
//

import SwiftUI

struct SmallGestureInfo: View {
    @State private var showText = true
    let input:Input
    
    var body: some View {
        HStack(alignment: .bottom) {
            Label(input.text1, systemImage: input.symbol1)
                .labelStyle(MyLabelStyle(alignedRight: false, color: .red, showText: showText))
            Label(input.text2, systemImage: input.symbol2)
                .labelStyle(MyLabelStyle(color: .secondary, showText: showText))
        }
        .onTapGesture { withAnimation { showText = !showText }}
    }
}

extension SmallGestureInfo {
    struct Input {
        let symbol1:String
        let text1:String
        
        let symbol2:String
        let text2:String
        
        init(_ symbol1: String, _ text1: String, _ symbol2: String, _ text2: String) {
            self.symbol1 = symbol1
            self.text1 = text1
            self.symbol2 = symbol2
            self.text2 = text2
        }
        
        static let clear = Input("xmark.square.fill", "Clear", "arrow.backward.circle.fill", "Swipe")
    }
}

struct SmallGestureInfo_Previews: PreviewProvider {
    static var previews: some View {
        SmallGestureInfo(input: .clear)
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

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
        HStack(alignment: .bottom, spacing: 4) {
            Label(input.text2, systemImage: input.symbol2)
                .labelStyle(MyLabelStyle(alignedRight: false, color: .secondary, showText: showText))
            Label(input.text1, systemImage: input.symbol1)
                .labelStyle(MyLabelStyle(color: input.color, showText: showText))
        }
        .onTapGesture { withAnimation { showText = !showText }}
    }
}

extension SmallGestureInfo {
    struct Input {
        let color:Color
        let symbol1:String
        let text1:String
        
        let symbol2:String
        let text2:String
        
        init(_ symbol1: String,
             _ text1: String,
             _ symbol2: String,
             _ text2: String,
             _ color:Color = .secondary) {
            
            self.symbol1 = symbol1
            self.text1 = text1
            self.symbol2 = symbol2
            self.text2 = text2
            self.color = color
        }
        
        static let clear = Input("delete.left.fill", "to clear",  "arrow.backward.circle.fill", "Swipe", .red)
        static let save = Input("square.and.arrow.down", "to Save", "hand.tap", "Tap")
        static let dismiss = Input("xmark.circle.fill", "to Dismiss", "hand.tap", "Tap")
    }
}

struct MyLabelStyle:LabelStyle {
    var alignedRight = true
    var color = Color.label
    var showText = true
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: alignedRight ? .leading :.trailing) {
            configuration.icon
                .foregroundColor(color)
            if showText {
                configuration.title
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SmallGestureInfo_Previews: PreviewProvider {
    static var previews: some View {
        SmallGestureInfo(input: .clear)
    }
}

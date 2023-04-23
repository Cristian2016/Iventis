//
//  InfoUnit.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.04.2023.
//

import SwiftUI

struct InfoUnit: View {
    let input:Input
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 3) {
                Text(input.keyword)
                    .fontWeight(.medium)
                Image(systemName: input.symbol)
                Text(input.gesture)
            }
            .font(.system(size: 20))
            if let footnote = input.footnote {
                Text(footnote)
                    .font(.footnote.italic())
                    .foregroundColor(.secondary)
            }
        }
    }
}

extension InfoUnit {
    struct Input {
        let keyword:LocalizedStringKey
        let symbol:String
        let gesture:String
        var footnote:LocalizedStringKey?
        
        static let bubbleTap = Input(keyword: "Toggle", symbol: "hand.tap.fill", gesture: "Tap", footnote: "tap seconds to start or pause")
        static let bubbleFinish = Input(keyword: "End", symbol: "target", gesture: "Long Press", footnote: "long press to end an entry")
        
        static let dpCreate = Input(keyword: "Create Timer", symbol: "hand.tap.fill", gesture: "Tap", footnote: "\(Image.roundCheckmark) checkmark confirms valid duration")
        
        static let dpClear = Input(keyword: "Clear", symbol: "arrow.backward.circle.fill", gesture: "Swipe", footnote: "any swipe direction works")
        
        static let dpDismiss = Input(keyword: "Dismiss", symbol: "hand.tap.fill", gesture: "Tap", footnote: "\(Image.roundCheckmark) checkmark is hidden")
        
        static let paletteStopwatch = Input(keyword: "Stopwatch", symbol: "hand.tap.fill", gesture: "Tap any color")
        static let paletteTimer = Input(keyword: "Timer", symbol: "target", gesture: "Long Press")
        static let paletteDismiss = Input(keyword: "Dismiss", symbol: "arrow.backward.circle.fill", gesture: "Swipe Left")
    }
}

struct InfoUnit_Previews: PreviewProvider {
    static var previews: some View {
        InfoUnit(input: .dpCreate)
    }
}

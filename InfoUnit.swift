//
//  InfoUnit.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.04.2023.
//

import SwiftUI

struct InfoUnit: View {
    let input:Input
    
    init(_ input: Input) { self.input = input }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 3) {
                Text(input.keyword)
                    .fontWeight(.medium)
                Image(systemName: input.symbol)
                Text(input.gesture)
            }
            .font(.system(size: 22))
            if let footnote = input.footnote {
                Text(footnote)
                    .font(.system(size: 19))
            }
        }
    }
}

extension InfoUnit {
    struct Input:Identifiable {
        let keyword:LocalizedStringKey
        let symbol:String
        let gesture:String
        var footnote:LocalizedStringKey?
        let id = UUID().uuidString
        
        static let bubbleStart = Input(keyword: "Start/Pause", symbol: "hand.tap.fill", gesture: "Tap")
        static let bubbleFinish = Input(keyword: "End", symbol: "target", gesture: "Long-Press", footnote: "to end an entry")
        
        static let showActivity = Input(keyword: "Show Activity", symbol: "hand.tap.fill", gesture: "Tap")
        static let addNote = Input(keyword: "Add Note", symbol: "target", gesture: "Long-Press")
        
        static let dpCreate = Input(keyword: "Create Timer", symbol: "hand.tap.fill", gesture: "Tap", footnote: "if \(Image.roundCheckmark) checkmark shows")
        
        static let dpClear = Input(keyword: "Clear", symbol: "arrow.backward.circle.fill", gesture: "Swipe", footnote: "any swipe direction works")
        
        static let dpDismiss = Input(keyword: "Dismiss", symbol: "hand.tap.fill", gesture: "Tap", footnote: "if duration is not valid yet")
        
        static let paletteStopwatch = Input(keyword: "Stopwatch", symbol: "hand.tap.fill", gesture: "Tap any color")
        static let paletteTimer = Input(keyword: "Timer", symbol: "target", gesture: "Long-Press")
        static let paletteDismiss = Input(keyword: "Dismiss", symbol: "arrow.backward.circle.fill", gesture: "Swipe Left")
    }
}

struct InfoUnit_Previews: PreviewProvider {
    static var previews: some View {
        InfoUnit(.dpDismiss)
    }
}

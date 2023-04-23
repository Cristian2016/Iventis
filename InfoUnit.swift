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
            HStack(spacing: 4) {
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
        
        static let bubbleTap = Input(keyword: "Start/Pause", symbol: "hand.tap.fill", gesture: "Tap")
        static let bubbleFinish = Input(keyword: "End", symbol: "target", gesture: "Long Press", footnote: "on seconds to end an entry")
    }
}

struct InfoUnit_Previews: PreviewProvider {
    static var previews: some View {
        InfoUnit(input: .bubbleFinish)
    }
}

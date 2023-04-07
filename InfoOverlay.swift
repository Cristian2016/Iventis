//
//  InfoOverlay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.04.2023.
//

import SwiftUI

struct InfoOverlay: View {
    var body: some View {
        VUnit(content: .bubbleDelete)
    }
}

extension InfoOverlay {
    struct VUnit:View {
        
        let content:Content
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("**\(content.title)**")
                    Image(systemName: content.symbol)
                    Text(content.symbolTitle)
                }
                if let detail = content.detail { Text("*\(detail)*") }
            }
        }
        
        struct Content {
            let title:String
            let symbol:String
            let symbolTitle:String
            var detail:String?
            
            static let bubbleDelete = Content.init(title: "Dismiss", symbol: "hand.tap.fill", symbolTitle: "Tap", detail: "outside Gray Shape")
        }
    }
}

struct InfoOverlay_Previews: PreviewProvider {
    static var previews: some View {
        InfoOverlay()
    }
}

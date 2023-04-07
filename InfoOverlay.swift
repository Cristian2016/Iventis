//
//  InfoOverlay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.04.2023.
//

import SwiftUI

struct InfoOverlay: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VUnit(content: .createTimer)
            VUnit(content: .remove)
            VUnit(content: .dismiss)
        }
    }
}

extension InfoOverlay {
    struct VUnit:View {
        
        let content:Content
        
        var body: some View {
            
            let keyword = content.title
            let symbol = Image.dic[content.symbol]!
            let symbolTitle = content.symbolTitle
            
            return VStack(alignment: .leading) {
                Text("**\(keyword)** \(symbol) \(symbolTitle)")
                if let detail = content.detail { Text(detail) }
            }
        }
        
        struct Content {
            let title:String
            let symbol:String
            let symbolTitle:String
            var detail:LocalizedStringKey?
            
            static let bubbleDelete = Self(title: "Dismiss", symbol: "tap", symbolTitle: "Tap", detail: "*outside Gray Shape*")
            static let createTimer = Self.init(title: "Create Timer", symbol: "tap", symbolTitle: "Tap", detail: "*if \(Image.roundCheckmark) symbol shows*")
            static let remove = Self(title: "Remove", symbol: "leftSwipe", symbolTitle: "Swipe", detail: "*in any direction*")
            static let dismiss = Self(title: "Dismiss", symbol: "tap", symbolTitle: "Tap", detail: "*if \(Image.roundCheckmark) symbol hidden*")
        }
    }
}

struct InfoOverlay_Previews: PreviewProvider {
    static var previews: some View {
        InfoOverlay()
    }
}

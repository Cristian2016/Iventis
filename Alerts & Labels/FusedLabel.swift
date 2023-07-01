//
//  FusedLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.01.2023.
//1 use LocalizedStringKey instead of String to be able to draw the image within the text

import SwiftUI

struct FusedLabel: View {
    let content:Content
    
    var body: some View {
        let text = condition ?
        LocalizedStringKey("\(Image(systemName: content.symbol!)) \(content.title)")
        : LocalizedStringKey(content.title)
        
        Text(text)//1
        .foregroundColor(content.isFilled ? .white : content.color)
        .padding([.leading, .trailing])
        .padding([.top, .bottom], 4)
        .font(font)
        .background { roundedRect }
    }
    
    @ViewBuilder
    private var roundedRect:some View {
        switch content.isFilled {
            case true: RoundedRectangle(cornerRadius: 8)
                    .fill(content.color)
            case false:
                RoundedRectangle(cornerRadius: 8)
                    .stroke(content.color)
        }
        
    }
    
    private var condition:Bool { content.symbol != nil }
    
    // MARK: - Convenience
    private var font:Font {
        switch content.size {
            case .small: return .footnote
            case .medium: return .callout
            case .large: return .title
        }
    }
    
    struct Content {
        let title:String
        var symbol:String? = nil
        var size:Size = .small
        var color:Color = .secondary
        var isFilled:Bool = false
        
        enum Size {
            case small
            case medium
            case large
        }
        
        static let alwaysON = Content(title: "Always-ON", symbol: "sun.max.fill")
        static let detailON = Content(title: "Detail is ON")
        static let scrollToTop = Content(title: "Scroll to Top")
        static func addNote(_ color:Color) -> Content {
            .init(title: "Add Note", symbol: "text.alignleft", color: color, isFilled: true)
        }
    }
}

struct FusedLabel_Previews: PreviewProvider {
    static var previews: some View {
        FusedLabel(content: .alwaysON)
    }
}

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
        Text(condition ?
             LocalizedStringKey("\(content.title) \(Image(systemName: content.symbol!))")
             : LocalizedStringKey(content.title)
        )//1
        .foregroundColor(content.isFilled ? .white : content.color)
        .padding([.leading, .trailing])
        .padding([.top, .bottom], 4)
        .font(font)
        .background {
            if content.isFilled {
                RoundedRectangle(cornerRadius: 8).fill(content.color)
            } else {
                RoundedRectangle(cornerRadius: 8).strokeBorder(content.color)
            }
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
        
        static let autoLockOff = Content(title: "Auto-Lock is OFF")
    }
}

struct FusedLabel_Previews: PreviewProvider {
    static var previews: some View {
        FusedLabel(content: .autoLockOff)
    }
}

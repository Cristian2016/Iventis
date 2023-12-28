//
//  FusedLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.01.2023.
//1 use LocalizedStringKey instead of String to be able to draw the image within the text
//2 explicitly specify both icon and text otherwise it will show only symbol. probbaly because it's in the toolbar

import SwiftUI

struct SmallFusedLabel: View {
    let content:Content
    
    var body: some View {
        let title = content.title
        
        Color.clear
            .aspectRatio(7.5, contentMode: .fit)
            .overlay {
                Text(title)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(content.color)
                    .minimumScaleFactor(0.1)
                    .padding([.leading, .trailing], 4)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.clear)
                            .stroke(.black)
                    }
            }
            .allowsHitTesting(false)
            .padding(.top, 6)
    }
}

extension SmallFusedLabel {
    struct Content {
        let title:String
        var color:Color = .secondary
    }
}

struct FusedLabel: View {
    let content:Content
    
    var body: some View {
        let title = content.title
        let image = content.symbol ?? ""
        let color = content.isFilled ? .white : content.color
        
        Label(title, systemImage: image) //1
            .labelStyle(.titleAndIcon) //2
            .foregroundStyle(color)
            .padding([.leading, .trailing])
            .padding([.top, .bottom], 6)
            .font(font)
            .background { roundedRect }
    }
    
    // MARK: - LEGO
    @ViewBuilder
    private var roundedRect:some View {
        switch content.isFilled {
            case true: RoundedRectangle(cornerRadius: 8).fill(content.color)
            case false: RoundedRectangle(cornerRadius: 8).stroke(content.color)
        }
    }
        
    // MARK: - Convenience
    private var font:Font {
        switch content.size {
            case .small: return .footnote
            case .medium: return .callout
            case .large: return .title
            case .verySmall: return .system(size: 14)
        }
    }
}

extension FusedLabel {
    struct Content {
        let title:String
        var symbol:String? = nil
        var size:Size = .small
        var color:Color = .secondary
        var isFilled:Bool = false
        
        enum Size {
            case verySmall
            case small
            case medium
            case large
        }
        
        static let alwaysON = Content(title: "Always-ON", symbol: "sun.max.fill")
        static let detailON = Content(title: "Detail is ON")
        static let scrollToTop = Content(title: "Scroll to Top")
        static func addNote(_ color:Color) -> Content {
            .init(title: "Lap Note", symbol: "text.alignleft", size: .medium, color: color, isFilled: true)
        }
    }
}

struct FusedLabel_Previews: PreviewProvider {
    static var previews: some View {
        FusedLabel(content: .alwaysON)
    }
}

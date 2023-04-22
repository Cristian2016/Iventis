//
//  InfoEntry.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.04.2023.
//

import SwiftUI

struct InfoEntry: View {
    let input:Input
    var kind = Kind.regular
    
    var body: some View {
        content
    }
    
    @ViewBuilder
    private var content:some View {
        switch kind {
            case .regular:
                VStack {
                    if let title = input.title {
                        Text(title)
                            .font(.system(size: 20))
                    }
                    if let subtitle = input.subtitle {
                        Text(subtitle)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                    if let imageName = input.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                    }
                    if let footnote = input.footnote {
                        Text(footnote)
                    }
                }
            case .small:
                VStack {
                    HStack(alignment: .bottom) {
                        if let title = input.title {
                            Text(title)
                                .font(.system(size: 20))
                        }
                        if let imageName = input.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 110)
                        }
                    }
                    if let footnote = input.footnote {
                        Text(footnote)
                            .font(.footnote.italic())
                            .foregroundColor(.secondary)
                    }
                }
            case .smallReversed: EmptyView()
        }
    }
}

extension InfoEntry {
    struct Input {
        var title:LocalizedStringKey?
        var subtitle:LocalizedStringKey?
        var imageName:String?
        var footnote:LocalizedStringKey?
        
        static let sec = Input(title: "**Start/Pause** \(Image.tap) Tap\n**Finish** \(Image.longPress) Long Press", imageName: "sec", footnote: "If bubble")
    }
    
    enum Kind {
        case regular
        case small
        case smallReversed
    }
}

struct InfoEntry_Previews: PreviewProvider {
    static var previews: some View {
        InfoEntry(input: InfoEntry.Input.sec, kind: .small)
    }
}

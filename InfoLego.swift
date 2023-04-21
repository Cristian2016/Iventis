//
//  InfoLego.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.04.2023.
//

import SwiftUI

struct InfoLego:View {
    let input:Input
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if let title = input.title {
                    Text(title)
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                }
                if let subtitle = input.subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            if let name = input.image {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
        }
    }
}

extension InfoLego {
    struct Input {
        var title:LocalizedStringKey?
        var subtitle:LocalizedStringKey?
        var image:String?
        
        static let bubbleSecondsArea = Input.init(title: "*Use Seconds to*", subtitle: "**Start/Pause** \(Image.tap) Tap\n**End Entry** \(Image.longPress) Long Press")
        static let bubbleYellowArea = Input.init(title: "*Use Yellow Area to*", subtitle: "**Show/Hide Activity** \(Image.tap) Tap\n**Add Note** \(Image.longPress) Long Press", image: "bubble")
        static let activity = Input.init(title: "1. Activity is made up of entries", subtitle: "***Show/Hide Activity** \(Image.tap) Tap yellow area*", image: "Untitled")
    }
}

struct InfoLego_Previews: PreviewProvider {
    static var previews: some View {
        InfoLego(input: InfoLego.Input.bubbleSecondsArea)
    }
}

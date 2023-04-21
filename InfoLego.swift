//
//  InfoLego.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.04.2023.
//

import SwiftUI

struct InfoLego:View {
    let input:Input
    var inverseColors = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if let title = input.title {
                    Text(title)
                        .foregroundColor(inverseColors ? .secondary : .black)
                        .fontWeight(.medium)
                }
                if let subtitle = input.subtitle {
                    Text(subtitle)
                        .foregroundColor(inverseColors ? .black : .secondary)
                }
            }
            if let name = input.image {
                Image(name)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

struct HInfoLego:View {
    let input:Input
    var inverseColors = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            if let name = input.image {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 110)
            }
            VStack(alignment: .leading) {
                if let title = input.title {
                    Text(title)
                        .foregroundColor(inverseColors ? .secondary : .black)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                if let subtitle = input.subtitle {
                    Text(subtitle)
                        .foregroundColor(inverseColors ? .black : .secondary)
                }
            }
        }
    }
}

extension HInfoLego {
    struct Input {
        var title:LocalizedStringKey?
        var subtitle:LocalizedStringKey?
        var image:String?
        
        static let bubbleSecondsArea = Input.init(title: "*Use Seconds to*", subtitle: "**Start/Pause Bubble** \(Image.tap) Tap\n**Finish Entry** \(Image.longPress) Long Press", image: "sec")
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

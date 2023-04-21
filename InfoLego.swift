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
            }
        }
    }
}

extension InfoLego {
    struct Input {
        var title:LocalizedStringKey?
        var subtitle:LocalizedStringKey?
        var image:String?
    }
}

struct InfoLego_Previews: PreviewProvider {
    static var previews: some View {
        InfoLego(input: InfoLego.Input.init(title: "1. Activity is made up of entries", subtitle: "***Toggle Activity** \(Image.tap) Tap minutes/hours*", image: "Untitled"))
    }
}

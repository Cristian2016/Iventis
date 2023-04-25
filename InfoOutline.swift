//
//  InfoOutline.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.04.2023.
//

import SwiftUI

struct InfoOutline: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("***\(Image.rightSwipe) Swipe right*** on a bubble and choose 'Cal ON'")
                    .font(.system(size: 20))
                Image("calOption")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                Text("*\(Image.alert) If asked, grant permission to Fused App to create events in Calendar App*")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                Divider()
                Text("\(Image.calendar) Calendar symbol in red appears")
                    .font(.system(size: 20))
                Image("calSymbol")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                Divider()
                Text("A calendar event will be created for each closed entry. To close an entry ***\(Image.longPress) long-press*** on seconds")
                    .font(.system(size: 20))
                Image("event.entry")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
            }
            .padding()
        }
    }
}

struct InfoOutline_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutline()
    }
}

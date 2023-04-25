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
                Text("\(Image.rightSwipe) Swipe right on a bubble and choose 'Cal ON'")
                    .font(.system(size: 20))
                Image("calOption")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                Text("*\(Image.alert) If asked, grant access to the Calendar App*")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                Divider()
                Text("\(Image.calendar) Calendar symbol appears")
                    .font(.system(size: 20))
                Image("calSymbol")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                Divider()
                Text("A calendar event will be created for each entry, if the entry is closed. To close an entry long-press on seconds. A confirmation will appear")
                    .font(.system(size: 20))
                Image("event.entry")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
            }
            .padding(10)
        }
    }
}

struct InfoOutline_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutline()
    }
}

//
//  InfoOutline.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.04.2023.
//

import SwiftUI

struct InfoOutline: View {
    
    let input:Input
    
    var body: some View {
        let layout = input.horizontal ? AnyLayout(HStackLayout(alignment: .bottom)) : AnyLayout(VStackLayout(alignment: .leading))
        VStack(alignment: .leading) {
            layout {
                Text(input.title)
                    .font(.system(size: 20))
                if let imageName = input.image {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                }
            }
            if let footnote = input.footnote {
                Text(footnote)
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
            }
            Divider()
        }
    }
}

extension InfoOutline {
    struct Input {
        var horizontal = false
        let title:LocalizedStringKey
        var image:String?
        var footnote:LocalizedStringKey?
        
        static let enableCal1 = Input(horizontal: true, title: "***\(Image.rightSwipe) Swipe right*** on a bubble and choose 'Cal ON'", image: "calOption", footnote: "*\(Image.alert) If asked, grant permission to creating events in the Calendar App*")
        static let enableCal2 = Input(horizontal: true, title: "Calendar symbol in red appears", image: "calSymbol")
        static let enableCal3 = Input(title: "A calendar event will be created for each closed entry. To close an entry ***\(Image.longPress) long-press*** on seconds", image: "event.entry")
    }
}

struct InfoOutline_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutline(input: .enableCal2)
    }
}

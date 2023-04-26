//
//  InfoOutline.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.04.2023.
//

import SwiftUI

struct InfoOutlineUnit: View {
    let input:Input
    
    var body: some View {
        let layout = input.horizontal ? AnyLayout(HStackLayout(alignment: .bottom)) : AnyLayout(VStackLayout(alignment: .leading))
        
        VStack(alignment: .leading) {
            layout {
                Text(input.title)
                    .font(.system(size: 22))
                
                if input.horizontal { Spacer() }
                
                if let imageName = input.image {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                }
            }
            if let footnote = input.footnote {
                Text(footnote)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
        }
        .forceMultipleLines()
    }
    
    init(_ input: Input) { self.input = input }
}

extension InfoOutlineUnit {
    struct Input:Identifiable {
        var horizontal = false
        let title:LocalizedStringKey
        var image:String?
        var footnote:LocalizedStringKey?
        
        let id = UUID().uuidString
        
        static let enableCal1 = Input(horizontal: true, title: "*\(Image.rightSwipe) Swipe right* on a bubble and choose 'Cal ON'", image: "calOption", footnote: "*\(Image.alert) If asked, grant permission to creating events in the Calendar App*")
        static let enableCal2 = Input(horizontal: true, title: "Calendar symbol in red appears", image: "calSymbol")
        static let enableCal3 = Input(title: "A calendar event will be created for each closed entry. To close an entry *\(Image.longPress) long-press* on seconds", image: "event.entry")
        
        static let aepActivity = Input(title: "The activity (activity log) represents the usage of a bubble over time", image: "bubbleActivity")
    }
}

struct InfoOutlineUnit_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutlineUnit(.enableCal1)
    }
}

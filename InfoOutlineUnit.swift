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
                        .frame(maxHeight: input.imageHeight)
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
        
        var imageHeight = CGFloat(150)
        
        let id = UUID().uuidString
        
        static let enableCal1 = Input(horizontal: true, title: "*\(Image.rightSwipe) Swipe right* on a bubble and choose 'Cal ON'", image: "calOption", footnote: "*\(Image.alert) If asked, grant permission to creating events in the Calendar App*")
        static let enableCal2 = Input(horizontal: true, title: "Calendar symbol in red appears", image: "calSymbol")
        static let enableCal3 = Input(title: "A calendar event will be created for each closed entry. To close an entry *\(Image.longPress) long-press* on seconds", image: "event.entry")
        
        static let aepActivity = Input(title: "A bubble's activity (activity log) represents its usage over time. The activity is made up of entries and each entry is made up of start-pause pairs", image: "bubbleActivity", footnote: "To view a bubble's activity *\(Image.tap) Tap* either its hours or minutes area")
        static let aepEntry = Input(title: "The very first entry is created when the user *\(Image.tap) Taps* seconds for the first time. To close an entry the user must  *\(Image.longPress) Long Press* on seconds", image: "entry")
        static let aepPair = Input(title: "A pair (start-pause pair) is a subunit of an entry. In other words each entry contains at least one pair. Each time the user starts and pauses a bubble, a new pair is created", image: "pair", footnote: "If an entry corresponds to a calendar event, the pairs of an entry are similar to the subevents of an event")
        
        static let aepActivityEntryPair = Input(title: "", image: "bubble.activity", imageHeight: 220)
    }
}

struct InfoOutlineUnit_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutlineUnit(.enableCal1)
    }
}

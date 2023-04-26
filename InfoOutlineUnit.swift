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
                if let title = input.title { Text(title).font(.system(size: 22)) }
                
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
        var title:LocalizedStringKey?
        var image:String?
        var footnote:LocalizedStringKey?
        
        var imageHeight = CGFloat(150)
        
        let id = UUID().uuidString
        
        static let enableCal1 = Input(horizontal: true, title: "*\(Image.rightSwipe) Swipe right* on a bubble and choose 'Cal ON'", image: "calOption", footnote: "*\(Image.alert) If asked, grant permission to creating events in the Calendar App*")
        static let enableCal2 = Input(horizontal: true, title: "Calendar symbol in red appears", image: "calSymbol")
        static let enableCal3 = Input(title: "A calendar event will be created for each closed entry. To close an entry *\(Image.longPress) long-press* on seconds", image: "event.entry")
        
        static let aepActivity = Input(title: "Activity (activity log) represents the bubble's usage over time. Activity groups entries together and each entry contains at least one start-pause pair", image: "bubbleActivity", footnote: "To view a bubble's activity *\(Image.tap) Tap* either the hours or minutes area")
        
        static let aepEntry = Input(title: "An entry groups pairs together. An entry (group of pairs) is similar to a calendar event. 'Calendar-enabled' bubbles have entries which correspond to calendar events. To separate entries from each other, the entries must be 'finished'. To finish an entry *\(Image.longPress) long-press* on seconds", image: "entry")
        
        static let aepPair = Input(title: "The pair (start-pause pair) is the simplest duration component. It has start and pause dates, a duration and optionally a user note. Each time the user taps seconds either a start or a pause date is registered. It means that two taps (a start followed by a pause) will generate a pair", image: "pair", footnote: "If an entry corresponds to a calendar event, the pairs of an entry are similar to the subevents of an event")
        
        static let aepActivityEntryPair = Input(image: "bubble.activity", imageHeight: 240)
    }
}

struct InfoOutlineUnit_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutlineUnit(.enableCal1)
    }
}

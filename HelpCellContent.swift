//
//  HelpCell.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.12.2023.
//

import SwiftUI

struct HelpCellContent:Identifiable, Hashable {
    let section:String
    
    //Title and symbol shows in the list
    let symbol:String
    let title:HelpDeepLink
    
    let subtitle:LocalizedStringKey
    let content:LocalizedStringKey
    var image:String?
    var image2:String?
    
    var id:String { title.rawValue }
    
    init(_ section: String,
         _ symbol:String,
         _ title: HelpDeepLink,
         _ subtitle: LocalizedStringKey,
         _ content: LocalizedStringKey,
         image:String? = nil, image2:String? = nil) {
        
        self.section = section
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
        self.content = content
        
        self.image = image
        self.image2 = image2
    }
    
    static let all = [
        .init("Tips", "w.circle.fill", .widgets, "Open Iventis from Lock Screen", "Widgets show the most recently used bubble", image: "lockscreen", image2: "widgets"),
        HelpCellContent("Tips", "calendar", .enableCalendar, "Swipe right on bubble > 'Cal ON'", "\(Image.calendar) symbol means bubble is 'calendar-enabled'", image: "bubble.enable.calendar", image2: "bubble.calendar.enabled"),
        .init("Tips", "calendar.badge.plus", .saveActivity, "Make sure bubble is [calendar-enabled](eventify://enableCalendar)", "As soon as you end a session, it will be saved as calendar event. Touch and hold seconds to end a session", image: "", image2: "bubble.save.activity"),
        .init("Tips", "link", .tetherBubbleCal, "Automatically add events to a calendar in Calendar App. Calendar App > 'Calendars' > '\(Image(systemName: "calendar.badge.plus")) Add Calendar' > Enter 'Calendar Name' > Tap 'Done'", ""),
        .init("Tips", "arrow.left.arrow.right.square", .changeBubble, "Swipe left on bubble > 'Control'", "Change to stopwatch: Tap \(Image.stopwatch)\nChange to timer:\n・Tap \(Image.timer), 5min, 10, etc. or\n・Swipe to choose a recent duration", image: "bubble.change", image2: "bubble.control"),
        .init("Tips", "bubble.left.and.text.bubble.right", .siriVoiceCommands, "", ""),
    ]
}

struct HelpCell:View {
    let content:HelpCellContent
    
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(content.subtitle)
                    .font(.system(size: 22))
                
                if let imageName = content.image {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }
                Text(content.content)
                    .font(.system(size: 20))
                
                if let imageName2 = content.image2 {
                    Image(imageName2)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .tint(.blue)
        .padding()
        .navigationTitle(Text(content.title.rawValue))
    }
}

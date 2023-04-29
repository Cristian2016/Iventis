//
//  Widgets.swift
//  Widgets
//
//  Created by Cristian Lapusan on 08.06.2022.
//policy .atEnd it's sort of like, 'don't call us, we call you' :)) in other words WidgetKit doesn't check at a date when to redraw the widget, instead App tells WidgetKit 'hey, do the update now'

import WidgetKit
import SwiftUI
import Intents
import MyPackage

struct Provider: IntentTimelineProvider {
    private let dataFetcher = DataFetcher()
    
    func placeholder(in context: Context) -> Entry {
        let input = Entry.Input(isRunning: false, startValue: 400, isTimer: false)
        return Entry(date: Date(), configuration: ConfigurationIntent(), input: input)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        
        let input = Entry.Input(isRunning: false, startValue: 400, isTimer: false)
        let entry = Entry(date: Date(), configuration: ConfigurationIntent(), input: input)
        completion(entry)
    }

    //called when manually refresh widgets
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print(#function)
        
        dataFetcher.fetch { bubbleData in
            var entries = [Entry]()
            
            let currentClock = TimeInterval(bubbleData.isTimer ? bubbleData.value : -bubbleData.value)
            
            let input = Entry.Input(isRunning: bubbleData.isRunning, startValue: currentClock, isTimer: bubbleData.isTimer)
            let entry = Entry(date: Date(), configuration: ConfigurationIntent(), input: input)
            
            entries.append(entry)
            
            if bubbleData.isTimer && bubbleData.isRunning {
                let endDate = Date().addingTimeInterval(TimeInterval(bubbleData.value))
                
                let input = Entry.Input(isRunning: false, startValue: 0, isTimer: bubbleData.isTimer)
               let finishedTimerEntry = Entry(date: endDate, configuration: ConfigurationIntent(), input: input)
                entries.append(finishedTimerEntry)
            }
            
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let input:Input
    
    struct Input {
        let isRunning:Bool
        let startValue:TimeInterval
        let isTimer:Bool
    }
}

@main
struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Activity")
        .description("Shows activity of most recently used bubble")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

//struct Widgets_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetView(entry: let entry = Entry(date: Date(), configuration: ConfigurationIntent(), isRunning: false, currentClock: 400))
//            .previewContext(WidgetPreviewContext(family: .accessoryInline))
//            .previewDisplayName("Inline")
//        WidgetView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//            .previewDisplayName("Rectangular")
//        WidgetView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
//    }
//}

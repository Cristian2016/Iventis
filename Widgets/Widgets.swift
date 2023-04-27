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
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries = [Entry]()

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Entry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

@main
struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("Track the most recently used bubble")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

//what shows onscreen
struct WidgetsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Circle().fill(.regularMaterial)
            .overlay {
                HStack {
                    Text(Date(), style: .timer)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
            }
    }
}


struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsEntryView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        WidgetsEntryView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
        WidgetsEntryView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
    }
}

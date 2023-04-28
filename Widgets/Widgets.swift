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
        Entry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries = [Entry]()

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
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Activity")
        .description("Shows activity of most recently used bubble")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .systemSmall])
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        WidgetView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
        WidgetView(entry: Entry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
    }
}

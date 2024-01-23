//
//  Widgets.swift
//  Widgets
//
//  Created by Cristian Lapusan on 18.01.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let dataFetcher = DataFetcher()
    
    func placeholder(in context: Context) -> Entry {
        let input = Entry.Input(isRunning: false, startValue: -200, isTimer: false)
        return Entry(date: Date(), input: input)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        
        let input = Entry.Input(isRunning: false, startValue: -200, isTimer: false)
        let entry = Entry(date: Date(), input: input)
        completion(entry)
    }
    
    //called when manually refresh widgets
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        dataFetcher.fetch { bubbleData in
            
            var entries = [Entry]()
            
            guard let bubbleData = bubbleData else {
                let entry = Entry(date: Date(), input: nil)
                completion(Timeline(entries: [entry], policy: .never))
                return
            }
            
            let currentClock = TimeInterval(bubbleData.isTimer ? bubbleData.value : -bubbleData.value)
            
            let input = Entry.Input(isRunning: bubbleData.isRunning, startValue: currentClock, isTimer: bubbleData.isTimer, color: bubbleData.color)
            let entry = Entry(date: Date(), input: input)
            
            entries.append(entry)
            
            if bubbleData.isTimer && bubbleData.isRunning {
                let endDate = Date().addingTimeInterval(TimeInterval(bubbleData.value))
                
                let input = Entry.Input(isRunning: false, startValue: 0, isTimer: bubbleData.isTimer, color: bubbleData.color)
                let finishedTimerEntry = Entry(date: endDate, input: input)
                entries.append(finishedTimerEntry)
            }
            
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

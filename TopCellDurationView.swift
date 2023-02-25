//
//  TopCellDurationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.02.2023.
//  when bubble isRunning, show > duration, else show duration

import SwiftUI

struct TopCellDurationView: View {
    private let duration: Float.TimeComponentsAsStrings?
    private let shouldDisplayDuration:Bool
    private let metrics:TopCell.Metrics
    
    var body: some View {
        if let duration = duration, shouldDisplayDuration {
            HStack (spacing: 8) {
                //hr
                if duration.hr != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.hr).font(metrics.durationFont)
                        Text("h").font(metrics.durationComponentsFont)
                    }
                }
                
                //min
                if duration.min != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.min).font(metrics.durationFont)
                        Text("m").font(metrics.durationComponentsFont)
                    }
                }
                
                //sec
                if showSeconds() {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.sec + "." + duration.hundredths).font(metrics.durationFont)
                        Text("s").font(metrics.durationComponentsFont)
                    }
                }
            }
        }
    }
    
    init(_ duration: Float.TimeComponentsAsStrings?, _ shouldDisplayDuration:Bool, _ metrics:TopCell.Metrics) {
        self.duration = duration
        self.shouldDisplayDuration = shouldDisplayDuration
        self.metrics = metrics
    }
    
    private func showSeconds() -> Bool {
        guard let duration = duration else { return false }
        
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
}

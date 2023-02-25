//
//  TopCellDurationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.02.2023.
//  when bubble isRunning, show > duration, else show duration

import SwiftUI

struct TopCellDurationView: View {
    private let duration: Float.TimeComponentsAsStrings
    private let shouldDisplayDuration:Bool
    private let metrics:TopCell.Metrics
    private let coordinator:PairBubbleCellCoordinator
    private let session:Session
    
    private let myRank:Int
    
    @State private var isPairBubbleCellRunning = false
    
    var body: some View {
        if shouldDisplayDuration {
            HStack (spacing: 8) {
                if isPairBubbleCellRunning && myRank == session.bubble?.sessions_.count {
                    Image.greaterThan
                }
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
            .onReceive(coordinator.$isPairBubbleCellRunning) { output in
                withAnimation { isPairBubbleCellRunning = output }
            }
        }
    }
    
    init?(_ duration: Float.TimeComponentsAsStrings?,
         _ shouldDisplayDuration:Bool,
         _ metrics:TopCell.Metrics,
         _ session:Session,
          _ myRank:Int) {
        
        guard
            let coordinator = session.bubble?.pairBubbleCellCoordinator,
            let duration = duration
        else { return nil }
        
        self.coordinator = coordinator
        
        self.duration = duration
        self.shouldDisplayDuration = shouldDisplayDuration
        self.metrics = metrics
        self.myRank = myRank
        self.session = session
    }
    
    private func showSeconds() -> Bool {
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
}

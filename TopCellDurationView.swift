//
//  TopCellDurationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.02.2023.
//  when bubble isRunning, show > duration, else show duration

import SwiftUI

struct TopCellDurationView: View {
    private let metrics:TopCell.Metrics
    //    private let coordinator:PairBubbleCellCoordinator
    
    @StateObject private var session:Session
    @State private var duration: Float.TimeComponentsAsStrings?
    @State private var showGreaterThenSymbol = false
    
    private let myRank:Int
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                //                if showGreaterThenSymbol {
                //                    Image.greaterThan.font(.caption2)
                //                }
                durationView
                    .overlay {
                        if showGreaterThenSymbol {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1) }
                    }
            }
        }
        .onAppear { handleOnAppear() }
        .onChange(of: session.totalDuration) { handleNewDuration($0) }
        .onChange(of: session.pairs_.last?.pause) { handlePauseDate($0) }
    }
    
    // MARK: - Legos
    @ViewBuilder
    private var durationView: some View {
        if let duration = duration {
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
    
    // MARK: - Methods
    private func showSeconds() -> Bool {
        guard let duration = duration else { return false }
        
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
    
    private func handleOnAppear() {
        if duration == nil {
            DispatchQueue.global().async {
                let components = session.totalDuration.timeComponentsAsStrings
                if components != .zeroAll {
                    DispatchQueue.main.async { self.duration = components }
                }
            }
        }
    }
    
    private func handleNewDuration(_ newDuration:Float) {
        if myRank == session.bubble?.sessions_.count {
            DispatchQueue.global().async {
                let components = newDuration.timeComponentsAsStrings
                DispatchQueue.main.async {
                    self.duration = components
                    self.showGreaterThenSymbol = false
                }
            }
        }
    }
    
    private func handlePauseDate(_ pauseDate:Date?) {
        if myRank == session.bubble?.sessions_.count {
            let isBubbleRunning = pauseDate == nil
            showGreaterThenSymbol = isBubbleRunning ? true : false
        }
    }
    
    // MARK: - Init
    init(_ metrics:TopCell.Metrics,
         _ session:Session,
         _ myRank:Int) {
        
        let isLatestSession = myRank == session.bubble?.sessions_.count
        let isBubbleRunning = session.bubble?.state == .running
        
        if isLatestSession && isBubbleRunning {
            self.showGreaterThenSymbol = (session.totalDuration != 0) ? true : false
        }
        
        self.metrics = metrics
        self.myRank = myRank
        _session = StateObject(wrappedValue: session)
    }
}

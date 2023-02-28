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
    @State private var isBubbleRunning = false
    @State private var showPlaceholder = false
    
    private let myRank:Int
    
    var body: some View {
        ZStack {
            if showPlaceholder {
                FusedLabel(content: .init(title: "Active", size: .small, color: .label, isFilled: false))
            } else {
                durationView
            }
        }
        .onAppear {
            if duration == nil {
                DispatchQueue.global().async {
                    let components = session.totalDuration.timeComponentsAsStrings
                    if components != .zeroAll {
                        DispatchQueue.main.async { self.duration = components }
                    } else {
                        if myRank == session.bubble?.sessions_.count {
                            showPlaceholder = true
                        }
                    }
                }
            }
        }
        .onChange(of: session.totalDuration) { newDuration in
            if myRank == session.bubble?.sessions_.count {
                DispatchQueue.global().async {
                    let components = newDuration.timeComponentsAsStrings
                    DispatchQueue.main.async { self.duration = components }
                }
            }
        }
        .onChange(of: session.pairs_.last?.pause) { pauseDate in
            if myRank == session.bubble?.sessions_.count {
                showPlaceholder = pauseDate == nil ? true : false
            }
        }
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
    
    // MARK: - Init
    init(_ metrics:TopCell.Metrics,
          _ session:Session,
          _ myRank:Int) {
                
        self.metrics = metrics
        self.myRank = myRank
        _session = StateObject(wrappedValue: session)
    }
}

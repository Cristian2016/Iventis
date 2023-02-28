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
    
    private let myRank:Int
    
    @State private var isPairBubbleCellRunning = false
    
    @ViewBuilder
    private var durationView: some View {
        //        let _ = print("duration view body \(duration!)")
        
        HStack {
            Text(duration?.hr ?? "e")
            Text(duration?.min ?? "e")
            Text(duration?.sec ?? "e")
        }
        
        //    private func showSeconds() -> Bool {
        //        guard let duration = duration else { return false }
        //
        //        let condition = (duration.min != "0" || duration.hr != "0")
        //        if duration.sec == "0" { return condition ? false : true }
        //        return true
        //    }
        
//        HStack (spacing: 8) {
//            //hr
//            if duration.hr != "0" {
//                HStack (alignment:.firstTextBaseline ,spacing: 0) {
//                    Text(duration.hr).font(metrics.durationFont)
//                    Text("h").font(metrics.durationComponentsFont)
//                }
//            }
//
//            //min
//            if duration.min != "0" {
//                HStack (alignment:.firstTextBaseline ,spacing: 0) {
//                    Text(duration.min).font(metrics.durationFont)
//                    Text("m").font(metrics.durationComponentsFont)
//                }
//            }
//
//            //sec
//            if showSeconds() {
//                HStack (alignment:.firstTextBaseline ,spacing: 0) {
//                    Text(duration.sec + "." + duration.hundredths).font(metrics.durationFont)
//                    Text("s").font(metrics.durationComponentsFont)
//                }
//            }
//        }
    }
    
    var body: some View {
        ZStack {
            durationView
        }
        .onChange(of: session.totalDuration) { newTotalDuration in
            DispatchQueue.global().async {
                let components = newTotalDuration.timeComponentsAsStrings
                DispatchQueue.main.async {
                    print(components)
                    self.duration = components
                }
            }
        }
    }
    
    init?(_ metrics:TopCell.Metrics,
          _ session:Session,
          _ myRank:Int) {
        
        guard
            let coordinator = session.bubble?.pairBubbleCellCoordinator
        else { return nil }
        
        //        self.coordinator = coordinator
        
        self.metrics = metrics
        self.myRank = myRank
        _session = StateObject(wrappedValue: session)
    }
}

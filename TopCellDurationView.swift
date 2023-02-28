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
    
    var body: some View {
        ZStack {
            if let duration = duration {
                Text(duration.hr + duration.min + duration.sec)
            }
        }
            .task {
                print("task")
                guard let data = session.totalDurationAsStrings else { return }
                guard let duration = try? JSONDecoder().decode(Float.TimeComponentsAsStrings.self, from: data) else { return }
                
                DispatchQueue.main.async {
                    self.duration = duration
                }
                
                session.totalDurationAsStrings
            }
            .onChange(of: session.totalDurationAsStrings) { newValue in
                print(newValue, " onChange")
            }
    }
    
//    var body: some View {
//        if duration != nil {
//            HStack (spacing: 8) {
//                if isPairBubbleCellRunning && myRank == session.bubble?.sessions_.count {
//                    Image.greaterThan
//                }
//                //hr
//                if duration.hr != "0" {
//                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
//                        Text(duration.hr).font(metrics.durationFont)
//                        Text("h").font(metrics.durationComponentsFont)
//                    }
//                }
//
//                //min
//                if duration.min != "0" {
//                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
//                        Text(duration.min).font(metrics.durationFont)
//                        Text("m").font(metrics.durationComponentsFont)
//                    }
//                }
//
//                //sec
//                if showSeconds() {
//                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
//                        Text(duration.sec + "." + duration.hundredths).font(metrics.durationFont)
//                        Text("s").font(metrics.durationComponentsFont)
//                    }
//                }
//            }
//
////            .onReceive(coordinator.$isPairBubbleCellRunning) { output in
////                withAnimation { isPairBubbleCellRunning = output }
////            }
//        } else {
//            EmptyView()
//                .task {
//                    print("task")
//                    guard let data = session.totalDurationAsStrings else {
//                        print("no data")
//                        return
//                    }
//                    guard let duration = try? JSONDecoder().decode(Float.TimeComponentsAsStrings.self, from: data) else {
//                        print("error")
//                        return }
//                    self.duration = duration
//
//                    print("session.totalDurationAsStrings \(session.totalDurationAsStrings)")
//                }
//        }
//    }
    
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
        
        DispatchQueue.global().async {
            if let data = session.totalDurationAsStrings {
              let result = try? JSONDecoder().decode(Float.TimeComponentsAsStrings.self, from: data)
                print(result, " result")
            }
        }
        session.totalDurationAsStrings
    }
    
    private func showSeconds() -> Bool {
        guard let duration = duration else { return false }
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
}

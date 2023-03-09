//
//  yPositionTracker.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.03.2023.
//1 track if at least one pinned bubble. do not track if

import SwiftUI

struct yPositionTracker: View {
    private static var initial:CGFloat! {didSet{
        print("initial was set \(Self.initial)")
    }}
    
    private let threshHold = CGFloat(50)
    private let secretary = Secretary.shared
    @State private var trackYPosition = false
    @State private var stop = false
    
    var body: some View {
        ZStack {
            if trackYPosition {
                Circle()
                    .fill(.clear)
                    .frame(height: 10)
                    .background {
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                let originY = geo.frame(in: .named("circle")).origin.y
                                if Self.initial == nil { Self.initial = originY }
                                let offset = originY - Self.initial
                                print("yOffset ", offset)
                                
                                if stop && offset < 1 && offset > 0 {
                                        stop = false
                                }
                                
                                if !stop {
                                    if offset > threshHold {
                                        secretary.showFavoritesOnly.toggle()
                                        stop = true
                                    }
                                }
                            }
                            return .clear
                        }
                    }
            }
        }
        .listRowSeparator(.hidden)
        .onReceive(secretary.$isBubblesReportReady) {
            print("report ready")
            if $0 { trackYPosition = secretary.bubblesReport.pinned == 0 ? false : true } //1
        }
    }
}

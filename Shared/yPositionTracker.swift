//
//  yPositionTracker.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.03.2023.
//1 track if at least one pinned bubble. do not track if

import SwiftUI

struct yPositionTracker: View {
    private let secretary = Secretary.shared
    @State private var track = false
    
    var body: some View {
        Circle()
            .frame(height: 10)
            .background {
                if track {
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            print(geo.frame(in: .named("circle")).origin.y)
                        }
                        return .clear
                    }
                }
            }
            .onReceive(secretary.$isBubblesReportReady) {
                if $0 { track = secretary.bubblesReport.pinned == 0 ? false : true } //1
            }
    }
}

struct yPositionTracker_Previews: PreviewProvider {
    static var previews: some View {
        yPositionTracker()
    }
}

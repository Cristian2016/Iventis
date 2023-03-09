//
//  ShowAllBubblesButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.02.2023.
//1 show RefresherView if there is at least one pinned bubble. otherwise do NOT show

import SwiftUI

///User pulls down on bubbleList and RefresherView shows up
struct RefresherView: View {
    private let secretary = Secretary.shared
    @State private var showFavoritesOnly = false
    @State private var show = false
    
    var body:some View {
        ZStack {
            if show {
                VStack(spacing: 4) {
                    let title = "Show Pinned Only"
                    let symbol = "pin"
                    let color = Color.orange
                    
                    BorderlessLabel(title: title, symbol: symbol,color: color)
                    Image(systemName: "chevron.compact.down")
                        .foregroundColor(color)
                    Spacer()
                }
                .opacity(showFavoritesOnly ? 0 : 1)
                .padding([.top], 4)
            }
        }
        .onReceive(secretary.$showFavoritesOnly) { showFavoritesOnly = $0 }
        .onReceive(secretary.$isBubblesReportReady) {
            if $0 { show = secretary.bubblesReport.pinned == 0 ? false : true } //1
        }
    }
}

struct ShowAllBubblesButton: View {
    private let secretary = Secretary.shared
    @State private var showFavoritesOnly = false
    
    var body: some View {
        ZStack {
            if showFavoritesOnly {
                Text("\(Image(systemName: "eye")) Show All")
                    .listRowSeparator(.hidden)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .onTapGesture { secretary.showFavoritesOnly = false }
                    .padding([.leading], 4)
            }
        }
        .onReceive(secretary.$showFavoritesOnly) { showFavoritesOnly = $0 }
    }
}

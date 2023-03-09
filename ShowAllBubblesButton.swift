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
                    let title = showFavoritesOnly ? "Show All" : "Show Pinned Only"
                    let symbol = showFavoritesOnly ? "eye" : "pin"
                    let color = showFavoritesOnly ? .secondary : Color.orange
                    
                    BorderlessLabel(title: title, symbol: symbol,color: color)
                    Image(systemName: "chevron.compact.down")
                        .foregroundColor(color)
                    Spacer()
                }
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
    @State private var count = 0
    @State private var colors = [Secretary.idColor]()
    
    var body: some View {
        ZStack {
            if showFavoritesOnly {
                HStack (spacing: 4) {
                    text
                    ForEach(colors.reversed()) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 10)
                    }
                }
                .onTapGesture { secretary.showFavoritesOnly = false }
            }
        }
        .onReceive(secretary.$showFavoritesOnly) { showFavoritesOnly = $0 }
        .onReceive(secretary.$isBubblesReportReady) { output in
            if output {
                count = secretary.bubblesReport.ordinary
                colors = secretary.bubblesReport.colors
            }
        }
    }
    
    // MARK: - Lego
    private var text:some View {
        Text("\(Image(systemName: "eye")) Show \(count)")
            .listRowSeparator(.hidden)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

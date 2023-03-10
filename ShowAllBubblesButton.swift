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
                    let symbol = showFavoritesOnly ? nil : "pin"
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
    @EnvironmentObject private var viewModel:ViewModel
    private let secretary = Secretary.shared
    @State private var showFavoritesOnly = false
    @State private var count = 0
    @State private var colors = [Secretary.idColor]()
    
    var body: some View {
        ZStack {
            if showFavoritesOnly {
                HStack (spacing: 4) {
                    text
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(colors.reversed()) { color in
                                Image(systemName: "circle.fill")
                                    .foregroundColor(color.color)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .onTapGesture { showAllBubbles()
                }
            }
        }
        .onReceive(secretary.$showFavoritesOnly) { showFavoritesOnly = $0 }
        .onReceive(secretary.$isBubblesReportReady) {
            if $0 {
                count = secretary.bubblesReport.ordinary
                colors = secretary.bubblesReport.colors
            }
        }
    }
    
    // MARK: - Lego
    private var text:some View {
        Text("Show \(count)")
            .listRowSeparator(.hidden)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    // MARK: -
    private func showAllBubbles() {
        withAnimation { secretary.showFavoritesOnly = false }
        viewModel.refreshOrdinaryBubbles()
    }
}

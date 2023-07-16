//
//  ShowAllBubblesButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.02.2023.
//1 show RefresherView if there is at least one pinned bubble. otherwise do NOT show

import SwiftUI

///User pulls down on bubbleList and RefresherView shows up
struct RefresherView: View {
    @Environment(Secretary.self) private var secretary
    private var show:Bool {
        if secretary.isBubblesReportReady {
            return secretary.bubblesReport.pinned == 0 ? false : true
        }
        
        return false
    }
    
    var body:some View {
        ZStack {
            if show {
                VStack(spacing: 4) {
                    let title = secretary.showFavoritesOnly ? "Show All" : "Show Pinned Only"
                    let symbol = secretary.showFavoritesOnly ? nil : "pin"
                    let color = secretary.showFavoritesOnly ? .secondary : Color.orange
                    
                    BorderlessLabel(title: title, symbol: symbol,color: color)
                    Image(systemName: "chevron.compact.down")
                        .foregroundStyle(color)
                    Spacer()
                }
                .padding([.top], 4)
            }
        }
    }
}

struct ShowAllBubblesButton: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(Secretary.self) private var secretary
    
    private var showFavoritesOnly:Bool { secretary.showFavoritesOnly }
    private var count:Int {
        if secretary.isBubblesReportReady {
           return secretary.bubblesReport.ordinary
        }
        return 0
    }
    private var colors:[Secretary.idColor] {
        if secretary.isBubblesReportReady {
           return secretary.bubblesReport.colors
        }
        
        return []
    }
    
    var body: some View {
        ZStack {
            if showFavoritesOnly {
                HStack (spacing: 4) {
                    text
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(colors.reversed()) { color in
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(color.color)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .onTapGesture { showAllBubbles()
                }
            }
        }
    }
    
    // MARK: - Lego
    private var text:some View {
        Text("Show \(count)")
            .listRowSeparator(.hidden)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    
    // MARK: -
    private func showAllBubbles() {
        withAnimation { secretary.showFavoritesOnly = false }
        viewModel.refreshOrdinaryBubbles()
    }
}

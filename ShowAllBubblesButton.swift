//
//  ShowAllBubblesButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.02.2023.
//

import SwiftUI

///User pulls down bubbleList and RefresherView shows up
struct RefresherView: View {
    private let secretary = Secretary.shared
    @State private var showFavoritesOnly = false
    
    var body:some View {
        ZStack {
            VStack(spacing: 4) {
                let condition = showFavoritesOnly
                let title = condition ?  "Show All" : "Show Pinned Only"
                let symbol = condition ? "eye" : "pin"
                let color = condition ? .secondary : Color.orange
                
                BorderlessLabel(title: title, symbol: symbol,color: color)
                Image(systemName: "chevron.compact.down")
                    .foregroundColor(color)
                Spacer()
            }
            .padding([.top], 4)
        }
        .onReceive(secretary.$showFavoritesOnly) { showFavoritesOnly = $0 }
    }
}

struct ShowAllBubblesButton: View {
    private let secretary = Secretary.shared
    @State private var showFavoritesOnly:Bool?
    let count = Secretary.shared.unpinnedBubblesCount
    
    var body: some View {
        ZStack {
            if let show = showFavoritesOnly, show {
                Text("\(Image(systemName: "eye")) Show \(count)")
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

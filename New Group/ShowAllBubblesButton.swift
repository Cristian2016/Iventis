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
    
    var body:some View {
        let _ = secretary.refresh
        
        ZStack {
            VStack(spacing: 4) {
                let title = secretary.showFavoritesOnly ? "Show All" : "Show Pinned Only"
                let symbol = secretary.showFavoritesOnly ? nil : "pin"
                let color = secretary.showFavoritesOnly ? .secondary : Color.orange
                
                BorderlessLabel(title: title, symbol: symbol,color: color)
                Image(systemName: "chevron.compact.down")
                    .foregroundStyle(color)
                Spacer()
            }
            .font(.title3)
            .padding([.top], 4)
        }
    }
}


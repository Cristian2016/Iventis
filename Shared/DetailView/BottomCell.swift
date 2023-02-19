//
//  PairsListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI
import MyPackage

///BottomCells swipe horizontally! each BottomCell contains a list that swipes vertically. The list contains PairCells
struct BottomCell: View {
    @FetchRequest var pairs:FetchedResults<Pair>
    
    ///how far from the trailing edge should the count label be
    let pairCountPadding = EdgeInsets(top: 4, leading: 0, bottom: 5, trailing: -6)
    
    init(_ session:Session) {
        let descriptor = NSSortDescriptor(key: "start", ascending: false)
        let predicate = NSPredicate(format: "session = %@", session)
        _pairs = FetchRequest(entity: Pair.entity(),
                              sortDescriptors: [descriptor],
                              predicate: predicate,
                              animation: .easeInOut)
    }
    
    var body: some View {
        List {
            ForEach(pairs) { pair in
                let pairNumber = pairs.count - pairs.firstIndex(of: pair)!
                PairCell(pair, pairNumber)
            }
            .listRowSeparator(.hidden)
            Spacer(minLength: 350)
                .listRowSeparator(.hidden)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .background {
            VStack {
                SmallAlertHintView(alertContent: AlertHint.scrollToTop)
                    .padding(2)
                Spacer()
            }
        }
        .refreshable {
            if !Secretary.shared.scrollToTop {
                Secretary.shared.scrollToTop = true
                print("scroll to top requested")
            }
        }
    }
}

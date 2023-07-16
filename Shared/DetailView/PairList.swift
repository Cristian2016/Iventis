//
//  PairsListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI
import MyPackage

///BottomCells swipe horizontally! each BottomCell contains a list that swipes vertically. The list contains PairCells
struct PairList: View {
    @FetchRequest var pairs:FetchedResults<Pair>
    
    @Environment(Secretary.self) private var secretary
    
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
        ScrollView {
            LazyVStack {
                ForEach(pairs) { pair in
                    if let pairIndex = pairs.firstIndex(of: pair) {
                        let pairNumber = pairs.count - pairIndex
                        PairCell(pair, pairNumber)
                    }
                }
            }
            Spacer(minLength: 350)
        }
        .refreshable {
            secretary.showDetailViewInfoButton.toggle()
            secretary.scrollToTop()
        }
    }
}

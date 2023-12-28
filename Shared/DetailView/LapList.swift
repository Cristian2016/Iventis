//
//  PairsListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI
import MyPackage

///BottomCells swipe horizontally! each BottomCell contains a list that swipes vertically. The list contains PairCells
struct LapList: View {
    @FetchRequest var laps:FetchedResults<Pair>
    
    @Environment(Secretary.self) private var secretary
    
    init(_ session:Session) {
        let descriptor = NSSortDescriptor(key: "start", ascending: false)
        let predicate = NSPredicate(format: "session = %@", session)
        _laps = FetchRequest(entity: Pair.entity(),
                             sortDescriptors: [descriptor],
                             predicate: predicate,
                             animation: .easeInOut)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(laps) {
                    if let lapIndex = laps.firstIndex(of: $0) {
                        let lapNumber = laps.count - lapIndex
                        LapCell($0, lapNumber)
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

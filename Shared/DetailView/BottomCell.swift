//
//  PairsListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

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
            ForEach(pairs) {
                PairCell($0, pairs.count - pairs.firstIndex(of: $0)!)
            }
            .listRowSeparator(.hidden)
            
            Spacer(minLength: 100).listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
}

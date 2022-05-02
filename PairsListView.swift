//
//  PairsListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairsListView: View {
    @FetchRequest var pairs:FetchedResults<Pair>
    
    init(session:Session) {
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
                PairCell($0)
            }
        }
    }
}

//struct PairsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PairsListView()
//    }
//}

//
//  PairsListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct BottomCell: View {
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
            ForEach(pairs) { pair in
                
                ZStack {
                    Push(.bottomRight) {
                        Image(systemName: "\(pairs.count - Int(pairs.firstIndex(of: pair)!)).square.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 25))
                    }
                    PairCell(pair: pair)
                }.padding(4)
            }
        }
        .listStyle(.grouped)
    }
}

//struct PairsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PairsListView()
//    }
//}

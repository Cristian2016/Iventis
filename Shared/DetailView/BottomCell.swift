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
                            .padding(pairCountPadding)
                            .foregroundColor(.lightGray)
                            .font(.system(size: 28))
                    }
                    PairCell(pair)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color("pairCell"))
                    .padding(2))
            //⚠️ it works but it shpuld be the size of screen.height - something...
            Rectangle()
                .fill(Color.clear)
                .frame(width: 10, height: 300)
        }
        .listStyle(.plain)
    }
}

//struct PairsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PairsListView()
//    }
//}

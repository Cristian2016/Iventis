//
//  BottomCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct BottomCell: View {
    let session:Session
    
    var body: some View {
        ScrollView {
            ForEach (0..<10) {
                Text("\($0)")
            }
//            ForEach (session.pairs_) { pair in
//                Text(DateFormatter.bubbleStyleDate.string(from: pair.start))
//            }
        }
    }
}

struct BottomCell_Previews: PreviewProvider {
    static var previews: some View {
        BottomCell(session: Session())
    }
}

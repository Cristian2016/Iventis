//
//  SmallPairBubbleCell.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.02.2023.
//

import SwiftUI

struct SmallPairBubbleCell: View {
    var body: some View {
        HStack (spacing: -60) {
            Circle()
            Circle()
            Circle()
        }
        .scaleEffect(x: 0.5, y: 0.5)
    }
}

struct SmallPairBubbleCell_Previews: PreviewProvider {
    static var previews: some View {
        SmallPairBubbleCell()
    }
}

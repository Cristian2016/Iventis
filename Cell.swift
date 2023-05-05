//
//  Cell.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 05.05.2023.
//

import SwiftUI

struct Cell: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .aspectRatio(2.0, contentMode: .fit)
            .overlay {
                ZStack {
                    HStack {
                        Circle()
                            .scale(x: 0.94, y: 0.94)
                        Circle()
                            .scale(x: 0.94, y: 0.94)
                    }
                    Circle()
                        .scale(x: 0.94, y: 0.94)
                }
            }
    }
}

struct Cell_Previews: PreviewProvider {
    static var previews: some View {
        Cell()
    }
}

//
//  ThreeCircles.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.12.2023.
//

import SwiftUI

struct Separator: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 26, height: 1)
                .overlay {
                    Rectangle()
                        .frame(width: 1, height: 10)
                        .offset(x: -8)
                }
            Spacer()
            Rectangle()
                .frame(width: 26, height: 1)
                .overlay {
                    Rectangle()
                        .frame(width: 1, height: 10)
                        .offset(x: 8)
                }
        }
        .foregroundStyle(Color.label2)
        .padding([.leading, .trailing], 2)
    }
}

#Preview {
    Separator()
}

//
//  TranslucentInterface.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.11.2023.
//

import SwiftUI

struct TranslucentInterface: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.blue)
                .offset(x: 0, y: -70)
                .padding()
                .padding()
            VStack {
                LazyVGrid(columns: [GridItem(spacing: 2),GridItem(spacing: 2), GridItem()], spacing: 2) {
                    ForEach(0..<12) { number in
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Text(String(number))
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(height: 50)
                }
            }
            .background(.ultraThinMaterial)
            .padding()
        }
    }
}

#Preview {
    TranslucentInterface()
}

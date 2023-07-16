//
//  Delete.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 27.12.2023.
//

import SwiftUI

struct Delete: View {
    var body: some View {
        Button {
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.ultraLightGray, lineWidth: 2)
                .fill(.white)
                .frame(width: 90, height: 90)
//                .standardShadow()
                .overlay {
                    Circle()
                        .fill(.white.shadow(.inner(color: .black.opacity(0.2), radius: 2.5, x: 1, y: 1)))
                        .padding(4)
                        .overlay {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 64, weight: .light))
                                .foregroundStyle(.blue)
                        }
                }
        }
        .padding(4)
    }
}

#Preview {
    Delete()
}

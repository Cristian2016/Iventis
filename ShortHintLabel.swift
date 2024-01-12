//
//  ShortHintLabel.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 19.01.2024.
//

import SwiftUI

struct ShortHintLabel: View {
    var body: some View {
        Text("Touch and hold to delete")
            .font(.system(size: 18))
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 1).stroke(.secondary, lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "xmark")
                    }
            }
            .foregroundStyle(.secondary)
    }
}

#Preview {
    ShortHintLabel()
}

//
//  ConfirmaLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.11.2023.
//

import SwiftUI

struct ConfirmLabel: View {
    var body: some View {
        Label("Stopwatch", systemImage: "stopwatch")
            .padding(10)
            .foregroundStyle(Color.label2)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ConfirmLabel()
}

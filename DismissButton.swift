//
//  DismissButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.10.2023.
//

import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button("Dismiss", systemImage: "xmark") {
            dismiss.callAsFunction()
        }
        .font(.system(size: 30))
        .labelStyle(.iconOnly)
        .foregroundStyle(.secondary)
        .padding()
    }
}

#Preview {
    DismissButton()
}

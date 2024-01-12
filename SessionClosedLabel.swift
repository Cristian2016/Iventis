//
//  SessionClosedLabel.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 22.01.2024.
//

import SwiftUI

struct SessionClosedLabel: View {
    var body: some View {
        Label("Closed", systemImage: "lock.fill")
            .padding(2)
            .background(Color.veryLightRed, in: .rect(cornerRadius: 4))
            .foregroundStyle(.red)
    }
}

#Preview {
    SessionClosedLabel()
}

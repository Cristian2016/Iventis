//
//  DismissHint.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 29.01.2024.
//

import SwiftUI

struct DismissHint: View {
    var body: some View {
        Label("Dismiss", systemImage: "xmark")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
            .allowsHitTesting(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
            .offset(y: 50)
    }
}

#Preview {
    DismissHint()
}

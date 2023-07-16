//
//  DPCheckmark.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import SwiftUI

extension DurationPickerOverlay {
    struct SmallCheckmark: View {
        let manager:Manager
        
        var body: some View {
            if manager.isDurationValid {
                Label("Tap", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 22))
                    .allowsHitTesting(false)
            }
        }
    }
}



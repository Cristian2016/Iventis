//
//  InfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.11.2023.
//

import SwiftUI

extension DurationPickerOverlay {
    struct InfoView: View {
        var body: some View {
            HStack(alignment: .top) {
                Image.dpv.thumbnail()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("*Use Yellow Areas to*")
                        .foregroundStyle(.secondary)
                    Divider()
                    InfoUnit(.dpCreate)
                    InfoUnit(.dpDismiss)
                    InfoUnit(.dpClear)
                }
            }
            .font(.system(size: 22))
        }
    }
}

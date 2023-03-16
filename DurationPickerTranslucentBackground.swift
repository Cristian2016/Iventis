//
//  DurationPickerTranslucentBackground.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.03.2023.
//

import SwiftUI

struct DurationPickerTranslucentBackground: View {
    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .background(.ultraThinMaterial)
    }
}

struct DurationPickerTranslucentBackground_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerTranslucentBackground()
    }
}

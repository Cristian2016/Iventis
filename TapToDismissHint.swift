//
//  TapToDismissHint.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.02.2023.
//

import SwiftUI

struct TapToDismissHint:View {
    var body: some View {
        Text("\(Image(systemName: "hand.tap")) Tap to Dismiss")
            .font(.caption)
            .foregroundColor(.secondary)
            .allowsHitTesting(false)
    }
}


struct TapToDismissHint_Previews: PreviewProvider {
    static var previews: some View {
        TapToDismissHint()
    }
}

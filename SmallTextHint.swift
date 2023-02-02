//
//  TapToDismissHint.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.02.2023.
//1 it doesn't intercept gestures

import SwiftUI

///A single line text!
struct SmallTextHint:View {
    let content:LocalizedStringKey
    var body: some View {
        Text(content)
            .font(.caption)
            .foregroundColor(.secondary)
            .allowsHitTesting(false) //1
    }
}


struct SmallTextHint_Previews: PreviewProvider {
    static var previews: some View {
        SmallTextHint(content: LocalizedStringKey("ok"))
    }
}

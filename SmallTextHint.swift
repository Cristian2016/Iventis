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
    var allowTouches:Bool = false
    
    var body: some View {
        Text(content)
            .font(.caption)
            .foregroundColor(.secondary)
            .allowsHitTesting(allowTouches) //1
    }
    
    static let tapToSave = SmallTextHint(content: "\(Image(systemName: "hand.tap")) Tap to Save")
    static let tapToDismiss = SmallTextHint(content: "\(Image(systemName: "hand.tap")) Tap to Dismiss")
    static let tapToScrollUp = SmallTextHint(content: "\(Image(systemName: "hand.tap")) Go to Top", allowTouches: true)
}


struct SmallTextHint_Previews: PreviewProvider {
    static var previews: some View {
        SmallTextHint.tapToScrollUp
    }
}

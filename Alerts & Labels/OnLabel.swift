//
//  OnOffView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct OnLabel: View {
    var isOn:Bool
    var hasBorder:Bool = true
    var color:Color?
    
    var body: some View {
        Label(isOn ? "ON" : "OFF", systemImage: isOn ? "checkmark" : "xmark")
            .font(.system(size: 30).weight(.medium))
            .padding([.leading, .trailing])
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(accentColor, lineWidth: 2)
            )
            .foregroundColor(accentColor)
    }
    
    var accentColor: Color {
        if hasBorder { return color ?? (isOn ? .green : .red) }
        else { return .clear }
    }
}

struct OnLabel_Previews: PreviewProvider {
    static var previews: some View {
        OnLabel(isOn: true)
    }
}

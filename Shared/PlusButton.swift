//
//  PlusButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 22.06.2022.
//

import SwiftUI

///tap PlusButton to show Palette [on iPad]
struct PlusButton: View {
    @Binding var isPaletteShowing:Bool
    private func showPalette() { withAnimation { isPaletteShowing = true } }
    let fontSize = CGFloat(30)
    
    var body: some View { button }
    
    private var button: some View {
        Button { showPalette() }
    label: { Label("", systemImage: "plus") }
            .font(.system(size: fontSize))
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton(isPaletteShowing: .constant(false))
    }
}

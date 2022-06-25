//
//  PlusButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 22.06.2022.
//

import SwiftUI

///tap PlusButton to show Palette [on iPad]
struct PlusButton: View {
    @EnvironmentObject var viewModel:ViewModel
    private func showPalette() { withAnimation { viewModel.isPaletteShowing = true } }
    let fontSize = CGFloat(30)
    
    var body: some View {
        Push(.topRight) { button}
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 20))
    }
    
    private var button: some View {
        Button { showPalette() }
    label: { Label("", systemImage: "plus") }
            .font(.system(size: fontSize))
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
    }
}

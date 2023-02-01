//
//  PlusButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 22.06.2022.
//

import SwiftUI

///tap PlusButton to show Palette [on iPad]
struct PlusSymbol: View {
    @EnvironmentObject var viewModel:ViewModel
    private func showPalette() { withAnimation { viewModel.isPaletteShowing = true } }
    private let metrics = Metrics()
    
    var body: some View {
        button
    }
    
    private var button: some View {
        Button { showPalette() }
    label: { Label("Plus", systemImage: "plus") }
            .font(metrics.font)
            .tint(metrics.symbolColor)
    }
    
    struct Metrics {
        let font = Font.system(.title2)
        let symbolColor = Color.secondary
        let diagonalLineColor = Color.red
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusSymbol()
    }
}

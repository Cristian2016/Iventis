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
    private let metrics = Metrics()
    private let secretary = Secretary.shared
    
    var body: some View {
        button
    }
    
    private var button: some View {
        Button { secretary.togglePaletteView() }
    label: { Label("Create New Bubble", systemImage: "plus") }
            .font(metrics.font)
            .tint(metrics.symbolColor)
    }
    
    struct Metrics {
        let font = Font.system(size: 18)
        let symbolColor = Color.label
        let diagonalLineColor = Color.red
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
    }
}

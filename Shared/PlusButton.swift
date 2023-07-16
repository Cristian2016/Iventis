//
//  PlusButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 22.06.2022.
//

import SwiftUI

///tap PlusButton to show Palette [on iPad]
struct PlusButton: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(Secretary.self) private var secretary
    
    private let metrics = Metrics()
    
    var body: some View {
        button
    }
    
    private var button: some View {
        Button { secretary.palette(.show) }
    label: { Label("Create New Bubble", systemImage: "plus") }
            .font(metrics.font)
    }
    
    struct Metrics {
        let font = Font.system(size: 18)
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
    }
}

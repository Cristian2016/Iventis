//
//  PlusButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 22.06.2022.
//

import SwiftUI

///tap PlusButton to show Palette [on iPad]
struct PlusButton: View {
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        Button {
            secretary.palette(.show)
        }
    label: {
        Label("New Bubble", systemImage: "plus")
    }
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
    }
}

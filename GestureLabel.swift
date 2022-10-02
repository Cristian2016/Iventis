//
//  GestureLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.10.2022.
//

import SwiftUI

struct GestureLabel: View {
    var body: some View {
        Label("Tap", systemImage: "list.bullet.rectangle")
            .padding([.leading, .trailing])
            .padding([.top, .bottom], 4)
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                .strokeBorder(.blue, lineWidth: 2)
            }
    }
}

struct GestureLabel_Previews: PreviewProvider {
    static var previews: some View {
        GestureLabel()
    }
}

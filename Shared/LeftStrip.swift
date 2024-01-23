//
//  InvisibleView.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.04.2022.
//

import SwiftUI

///user swipes right from screen edge and Palette is presented
struct LeftStrip: View {
    @Environment(Secretary.self) private var secretary
    
    // MARK: -
    var body: some View {
        Color.clear
            .frame(width: 40)
            .contentShape(.rect) //use if color clear otherwise gesture will not work
            .ignoresSafeArea()
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onEnded { _ in
                        secretary.palette(.show)
                    }
            )
    }
}

//
//  InvisibleView.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.04.2022.
//

import SwiftUI

///user swipes right from screen edge and Palette is presented
struct RightSwipeStripView: View {
    @Binding var isPalettePresented:Bool
    
    var body: some View {
        HStack {
            Rectangle().fill(Color.clear).frame(width: 20)
                .contentShape(Rectangle()) //use if color clear otherwise gesture will not work
            Spacer()
        }
        .ignoresSafeArea()
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onEnded { _ in
                isPalettePresented = true
            })
    }
}

struct InvisibleView_Previews: PreviewProvider {
    static var previews: some View {
        RightSwipeStripView(isPalettePresented: .constant(true))
    }
}

//
//  InvisibleView.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.04.2022.
//

import SwiftUI

///user swipes right from screen edge and Palette is presented
struct LeftStrip: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(Secretary.self) private var secretary
    
    let isListEmpty:Bool
    
    // MARK: -
    var body: some View {
        HStack {
            Color.clear
                .frame(width: 40)
                .contentShape(Rectangle()) //use if color clear otherwise gesture will not work
            Spacer()
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture(minimumDistance: 1)
                .onEnded { _ in secretary.palette(.show) }
        )
    }
    
    // MARK: -
    init(_ isListEmpty:Bool) {
        self.isListEmpty = isListEmpty
    }
}

///user swipes left from screen edge and Palette is dismissed
struct RightStrip: View {
    @Binding var showPalette:Bool
    init(_ showPalette:Binding<Bool>) {
        _showPalette = .init(projectedValue: showPalette)
    }
    
    // MARK: -
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 20)
            .contentShape(Rectangle()) //use if color clear otherwise gesture will not work
            .ignoresSafeArea()
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onEnded { _ in
                    
                }
            )
    }
}

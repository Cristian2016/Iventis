//
//  InvisibleView.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.04.2022.
//

import SwiftUI

///user swipes right from screen edge and Palette is presented
struct LeftStrip: View {
    @Binding var showPalette:Bool
    
    // MARK: -
    var body: some View {
        HStack {
            Rectangle().fill(Color.clear).frame(width: 20)
                .contentShape(Rectangle()) //use if color clear otherwise gesture will not work
            Spacer()
        }
        .ignoresSafeArea()
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onEnded { _ in
                withAnimation {
                    showPalette = true
                }
            })
    }
    
    // MARK: -
    init(_ showPalette:Binding<Bool>) {
        _showPalette = .init(projectedValue: showPalette)
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
        Rectangle().fill(Color.clear).frame(width: 20)
            .contentShape(Rectangle()) //use if color clear otherwise gesture will not work
            .ignoresSafeArea()
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onEnded { _ in
                    withAnimation {
                        showPalette = false
                    }
                })
    }
}

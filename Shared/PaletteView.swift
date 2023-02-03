//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct PaletteView: View {
    @EnvironmentObject private var viewModel:ViewModel
    @Binding private var showPalette:Bool
    private let xOffset = -UIScreen.main.bounds.width
    
    private let tricolors = [
        Color.Bubbles.mint, Color.Bubbles.slateBlue, Color.Bubbles.sourCherry, Color.Bubbles.silver, Color.Bubbles.ultramarine, Color.Bubbles.lemon, Color.Bubbles.red, Color.Bubbles.sky, Color.Bubbles.bubbleGum,  Color.Bubbles.green, Color.Bubbles.charcoal, Color.Bubbles.magenta, Color.Bubbles.purple, Color.Bubbles.orange, Color.Bubbles.chocolate
    ]
        
    private let colums = Array(repeating: GridItem(), count: 3)
    
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                paletteView
                RightStrip($showPalette)
            }
            .offset(x: !showPalette ? -geo.size.width * 1.05 : 0, y: 0)
        }
    }
    
    // MARK: -
    private var paletteView:some View {
        ZStack {
            background
            circles
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onEnded { _ in
                withAnimation { showPalette = false }
            }
        )
    }
    
    // MARK: - Legoes
    var background: some View {
        Color.background
            .standardShadow()
            .ignoresSafeArea()
    }
                              
    var circles:some View {
        ScrollView {
            LazyVGrid(columns: colums, spacing: 10) {
                ForEach(tricolors, id:\.self) { tricolor in
                    Circle()
                        .fill(tricolor.sec)
                        .onTapGesture {
                            viewModel.createBubble(.stopwatch, tricolor.description)
                            showPalette = false
                        }
                        .onLongPressGesture { viewModel.durationPicker_OfColor = tricolor.sec }
                }
            }
        }
        .padding([.trailing, .leading, .bottom], 2)
        .scrollIndicators(.hidden)
    }
    
    private func circle(_ color:Color.Tricolor) -> some View {
        Circle().fill(color.sec)
            
    }
    
    // MARK: -
    init(_ showPalette:Binding<Bool>) {
        _showPalette = .init(projectedValue: showPalette)
    }
}

struct PaletteView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteView(.constant(true))
    }
}

extension Image {
    static let tapHold = Image("taphold")
}

struct ShadowModifier:ViewModifier {
    let opacity:CGFloat
    func body(content:Content) -> some View {
        content.shadow(color: .black.opacity(opacity), radius: 4, y: 2.5)
    }
}

extension View {
    //https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
    //https://www.youtube.com/watch?v=nGENKnaSWPM
    func standardShadow(_ opacity:CGFloat = 0.3) -> some View {
        modifier(ShadowModifier(opacity: opacity))
    }
}

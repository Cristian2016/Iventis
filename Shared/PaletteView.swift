//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct PaletteView: View {
    @EnvironmentObject private var vm:ViewModel
    @Binding private var showPalette:Bool
    private let xOffset = -UIScreen.main.bounds.width
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                paletteView
                RightStrip($showPalette)
            }
            .offset(x: !showPalette ? -geo.size.width * 1.05 : 0, y: 0)
        }
    }
    
    // MARK: -
    private var paletteView:some View {
        GeometryReader { geo in
            ZStack {
                background
                circles
            }}
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
        VStack {
            HStack(spacing:-20) {
                circle(Color.Bubbles.mint)
                circle(Color.Bubbles.slateBlue)
                circle(Color.Bubbles.sourCherry)
            }
            HStack(spacing:-20) {
                circle(Color.Bubbles.silver)
                circle(Color.Bubbles.ultramarine)
                circle(Color.Bubbles.lemon)
            }
            
            HStack(spacing:-20) {
                circle(Color.Bubbles.red)
                circle(Color.Bubbles.sky)
                circle(Color.Bubbles.bubbleGum)
            }
            HStack(spacing:-20) {
                circle(Color.Bubbles.green)
                circle(Color.Bubbles.charcoal)
                circle(Color.Bubbles.magenta)
            }
            HStack(spacing:-20) {
                circle(Color.Bubbles.purple)
                circle(Color.Bubbles.orange)
                circle(Color.Bubbles.chocolate)
            }
        }
        .padding([.trailing, .leading, .bottom], 3)
    }
    
    private func circle(_ color:Color.Three) -> some View {
        Circle().fill(color.sec)
            .onTapGesture {
                vm.createBubble(.stopwatch, color.description)
                showPalette = false
            }
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
    func body(content:Content) -> some View {
        content.shadow(color: .black.opacity(0.3), radius: 4, y: 2.5)
    }
}

extension View {
    //https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
    //https://www.youtube.com/watch?v=nGENKnaSWPM
    func standardShadow() -> some View {
        modifier(ShadowModifier())
    }
}

//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct PaletteView: View {
    @Binding private var showPalette:Bool
    private let xOffset = -UIScreen.main.bounds.width
    
    var body: some View {
        HStack {
            paletteView.offset(x: !showPalette ? xOffset : 0, y: 0)
            RightStrip($showPalette)
        }
    }
    
    // MARK: -
    private var paletteView:some View {
        GeometryReader { geo in
            ZStack {
                background
                circles
            }}
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
                circle(Color.Bubbles.coffee)
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
                let colorDescription = color.description
                print(colorDescription)
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
        content.shadow(radius: 2)
    }
}

extension View {
    func standardShadow() -> some View {
        modifier(ShadowModifier())
    }
}

//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct PaletteView: View {
    var body: some View {
        ZStack {
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
            .ignoresSafeArea()
            .padding()
            .padding()
            
            TapHold()
                .frame(width: 400, height: 150)
        }
        
    }
    
    func circle(_ color:Color.Three) -> some View {
        Circle().fill(color.sec)
            .onTapGesture {
                let colorDescription = color.description
                print(colorDescription)
            }
    }
}

struct PaletteView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteView()
    }
}

extension Image {
    static let tapHold = Image("taphold")
}

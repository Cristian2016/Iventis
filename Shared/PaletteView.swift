//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct PaletteView: View {
    var body: some View {
        VStack {
            Label {
                Text("Tap")
            } icon: {
                Image(systemName:"circle")
            }

            HStack(spacing:-20) {
                circle(.Bubbles.mint.sec)
                circle(.Bubbles.slateBlue.sec)
                circle(.Bubbles.sourCherry.sec)
            }
            HStack(spacing:-20) {
                circle(.Bubbles.silver.sec)
                circle(.Bubbles.ultramarine.sec)
                circle(.Bubbles.lemon.sec)
            }
            HStack(spacing:-20) {
                circle(.Bubbles.red.sec)
                circle(.Bubbles.sky.sec)
                circle(.Bubbles.bubbleGum.sec)
            }
            HStack(spacing:-20) {
                circle(.Bubbles.green.sec)
                circle(.Bubbles.coffee.sec)
                circle(.Bubbles.magenta.sec)
            }
            HStack(spacing:-20) {
                circle(.Bubbles.purple.sec)
                circle(.Bubbles.orange.sec)
                circle(.Bubbles.chocolate.sec)
            }
        }
        .ignoresSafeArea()
        .padding(4)
    }
    
    func circle(_ color:Color) -> some View {
        Circle().fill(color)
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

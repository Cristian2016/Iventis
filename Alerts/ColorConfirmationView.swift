//
//  ColorConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.09.2022.
//

import SwiftUI

struct ColorConfirmationView: View {
    let colorName:String
    let color:Color
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.9)
            Circle().fill(color)
                .padding()
                .padding()
                .standardShadow(true)
            Text(Color.userFriendlyBubbleColorName(for: colorName))
                .font(.system(size: 40).weight(.medium))
                .foregroundColor(.white)
                .padding()
        }
    }
}

struct ColorConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ColorConfirmationView(colorName: "Magenta", color: Color.Bubbles.magenta.sec)
    }
}

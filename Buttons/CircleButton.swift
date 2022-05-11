//
//  CircleButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 11.05.2022.
//

import SwiftUI

struct CircleButton: View {
    var body: some View {
        Button {
            
        } label: { Text("Button") }
        .buttonStyle(CircleStyle(color:.red, edge:130, font: .system(size: 23)))
    }
}

struct CircleStyle : ButtonStyle {
    let color:Color
    let edge:CGFloat
    let font:Font
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(font)
            .background {
                Circle()
                    .frame(width: edge, height: edge)
                    .foregroundColor(color)
            }
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton()
    }
}

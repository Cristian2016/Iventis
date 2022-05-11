//
//  ScaleDownButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 10.05.2022.
//

import SwiftUI

struct ScaleDownButton: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Im ok")
        }
        .buttonStyle(ScaleDownButtonStyle(color: .red))
    }
}

struct ScaleDownButtonStyle : ButtonStyle {
    let color:Color
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    let radius = CGFloat(13)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(color)
            .font(.system(size: 30).weight(.medium))
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .cornerRadius(radius)
            .frame(width: width, height: width * ratio)
            .padding([.bottom], 6)
    }
}

struct ScaleDownButton_Previews: PreviewProvider {
    static var previews: some View {
        ScaleDownButton()
    }
}

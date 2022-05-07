//
//  DeleteButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct DeleteButton: View {
    var body: some View {
        ZStack {
            Button {
                
            } label: {
                Text("OK")
            }
            .buttonStyle(DeleteButtonStyle(color: .red, title: "Bubble"))
        }
        .padding()
    }
}

struct DeleteButtonStyle : ButtonStyle {
    let radius = CGFloat(13)
    let color:Color
    let ratio = CGFloat(503/238)
    let width = CGFloat(200)
    let title:String
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
                .frame(width: width, height: width / ratio)
            Text(title)
                .font(.system(size: 30).weight(.medium))
        }
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton()
    }
}

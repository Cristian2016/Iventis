//
//  DeleteButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct DeleteButton: View {
    let title:String
    
    var body: some View {
        ZStack {
            Button {
                
            } label: {
                Text(title)
                    .font(.system(size: 30).weight(.medium))
                    .foregroundColor(.white)
            }
            .buttonStyle(DeleteButtonStyle(color: .red))
        }
        .padding()
    }
}

struct DeleteButtonStyle : ButtonStyle {
    let radius = CGFloat(13)
    let color:Color
    let ratio = CGFloat(503/238)
    let width = CGFloat(200)
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
                .frame(width: width, height: width / ratio)
        }
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton(title: "History")
    }
}

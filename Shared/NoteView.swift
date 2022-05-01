//
//  Note.swift
//  Time Dots
//
//  Created by Cristian Lapusan on 08.04.2022.
//

import SwiftUI

struct NoteView: View {
    let content:String
    let lineWidth:CGFloat
    let cornerRadius:CGFloat
    
    let aspectRatio:CGFloat = 2.1
    let height = CGFloat(46)
    
    init(content:String, lineWidth:CGFloat = 3, radius:CGFloat = 0) {
        self.content = content
        self.lineWidth = lineWidth
        self.cornerRadius = radius
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Label { Text(content) } icon: { }
                Spacer()
            }
            .background(border)
            .background(background)
        }
        .frame(width: height * aspectRatio, height: height)
        .padding()
        .foregroundColor(.black)
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(.background1)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .shadow(radius: 2)
    }
    
    var border: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(lineWidth: lineWidth, antialiased: true)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .foregroundColor(.white)
    }
}

struct Note_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoteView(content: "Workout")
            NoteView(content: "Work").preferredColorScheme(.dark)
        }
    }
}

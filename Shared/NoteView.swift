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
    
    let aspectRatio:CGFloat = 2.33
    let height = CGFloat(44)
    
    init(content:String, lineWidth:CGFloat = 3, radius:CGFloat = 0) {
        self.content = content
        self.lineWidth = lineWidth
        self.cornerRadius = radius
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Label { Text(content)
                    .font(.system(size: 26)) } icon: { }
                Spacer()
            }
            .background(background)
        }
        .frame(width: height * aspectRatio, height: height)
        .padding()
        .foregroundColor(.black)
    }
    
    var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .scaleEffect(0.4)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.clear)
                .background(.thinMaterial)
                .aspectRatio(aspectRatio, contentMode: .fill)
                .cornerRadius(2)
                .standardShadow(false)
        }
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

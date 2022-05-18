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
    
    let ratio:CGFloat
    let height = CGFloat(44)
    
    init(content:String, lineWidth:CGFloat = 3, radius:CGFloat = 0) {
        self.content = content
        self.ratio = (content.count < 8) ? CGFloat(2.7) : 2.7
        self.lineWidth = lineWidth
        self.cornerRadius = radius
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Label { Text(content)
                        .foregroundColor(.label)
                    .font(.system(size: 26)) } icon: { }
                Spacer()
            }
            .background(background)
        }
        .frame(width: height * ratio, height: height)
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
                .aspectRatio(ratio, contentMode: .fill)
                .cornerRadius(2)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
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

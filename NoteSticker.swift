//
//  NoteSticker.swift
//  Timers
//
//  Created by Cristian Lapusan on 18.05.2022.
//

import SwiftUI

struct NoteSticker: View {
    let calRatio:CGFloat = 98.0/91.0
    
    var body: some View {
        ZStack {
            Image(systemName: "note.text")
                .foregroundColor(Color(.blue))
                .font(.system(size: 38))
        }
    }
}

struct NoteSticker_Previews: PreviewProvider {
    static var previews: some View {
        NoteSticker()
    }
}

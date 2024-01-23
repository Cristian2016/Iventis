//
//  InfoView.swift
//  TestUI
//
//  Created by Cristian Lapusan on 14.10.2023.
//

import SwiftUI

struct DeleteNoteInList:View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack {
            Text("Delete Note")
            Image(isDark ? "deleteNoteInListDark" : "deleteNoteInList")
                .resizable()
                .modifier(ImageModifier())
        }
    }
}

struct ImageModifier:ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
    }
}

struct ClearSaveHintView:View {
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                Text("Clear")
                Image.swipeBidirectional
                    .font(.title2)
                    .frame(height: 40)
                Text("Swipe")
                    .font(.system(size: 17))
            }
            
            Divider().frame(maxHeight: 100)
            
            VStack(spacing: 4) {
                Text("Save")
                Image.dragDown
                    .font(.title2)
                    .frame(height: 40)
                Text("Drag")
                    .font(.system(size: 17))
            }
        }
        .font(.system(size: 22))
        .foregroundStyle(.secondary)
        .fixedSize()
    }
}

#Preview {
    ClearSaveHintView()
}

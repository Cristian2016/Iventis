//
//  InfoView.swift
//  TestUI
//
//  Created by Cristian Lapusan on 14.10.2023.
//

import SwiftUI

struct SaveText: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var text:String = "Save"
    
    var body: some View {
        let isLight = colorScheme == .light
        VStack {
            Text(text)
            Image(isLight ? "saveText" : "saveTextDark")
                .resizable()
                .modifier(ImageModifier())
        }
    }
}

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
            .frame(height: 140)
    }
}

struct ClearText:View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack(spacing: 6) {
            Text("Clear")
            Image(isDark ? "clearTextDark" : "clearText")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 140)
        }
    }
}

struct InfoView2:View {
    var body: some View {
        HStack(alignment: .bottom) {
            ClearText()
            SaveText()
            DeleteNoteInList()
        }
        .font(.system(size: 14))
//        .padding(.top)
    }
}

#Preview {
    InfoView2()
}

//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//

import SwiftUI

struct BubbleNoteView: View {
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    private var bubbles:FetchedResults<Bubble>
    
    @State var searchText:String = ""
    @Binding var showBubbleNoteView:Bool
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture { showBubbleNoteView = false }
            NavigationView {
                List (bubbles) { bubble in
                    Text(bubble.note_)
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search or Add Note")
            }
            .frame(width: 300, height: 500)
        }
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNoteView(showBubbleNoteView: .constant(true))
    }
}

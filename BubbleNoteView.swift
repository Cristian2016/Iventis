//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o

import SwiftUI

struct BubbleNoteView: View {
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    private var bubbles:FetchedResults<Bubble>
    
    @State var searchText:String = ""
    @Binding var showBubbleNoteView:Bool
    @FocusState var isTyping:Bool
    
    init(_ showBubbleNoteView:Binding<Bool>) {
        _showBubbleNoteView = Binding(projectedValue: showBubbleNoteView)
    }
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture { showBubbleNoteView = false }
            NavigationView {
                List {
                    ForEach (bubbles) { bubble in
                        Text(bubble.note_)
                    }
                }
                .focused($isTyping)
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search or Add Note")
                .onAppear {
                    isTyping = true
                }
            }
            .frame(width: 300, height: 500)
        }
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNoteView(.constant(true))
    }
}

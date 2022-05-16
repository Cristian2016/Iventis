//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o

import SwiftUI

struct BubbleNotesView: View {
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    private var bubbles:FetchedResults<Bubble>
    
    @State var searchString:String = ""
    @Binding var showBubbleNoteView:Bool
    @FocusState var isTyping:Bool
    
    init(_ showBubbleNoteView:Binding<Bool>) {
        _showBubbleNoteView = Binding(projectedValue: showBubbleNoteView)
    }
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture { showBubbleNoteView = false }
            RoundedRectangle(cornerRadius: 24)
                .frame(width: 250, height: 400)
                .foregroundColor(Color("deleteActionViewBackground"))
                .overlay {
                    VStack {
                        Spacer(minLength: 30)
                        TextField("Search or Add Note", text: $searchString)
                            .focused($isTyping)
                            .foregroundColor(Color("deleteActionViewBackground"))
                        List {
                            ForEach (bubbles) { bubble in
                                Text(bubble.note_)
                            }
                        }
                        .listStyle(.plain)
                        .listRowBackground(Color("deleteActionViewBackground"))
                        .listRowSeparator(.hidden)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
        }
        .onAppear {
            delayExecution(.now() + 0.05) {
                isTyping = true
            }
        }
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNotesView(.constant(true))
    }
}

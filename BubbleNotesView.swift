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
                .foregroundColor(Color("searchFieldBackground"))
                .standardShadow(false)
                .overlay {
                    VStack {
                        Spacer(minLength: 14)
                        TextField("Search/Add Note", text: $searchString)
                            .focused($isTyping)
                            .font(.title2)
                            .padding()
                            .onSubmit {
                                print("searchField \(searchString)")
                            }
                        List {
                            ForEach (bubbles) { bubble in
                                Text(bubble.note_)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color("deleteActionViewBackground"))
                        }
                        .listStyle(.plain)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
        }
        .onAppear { isTyping = true }
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNotesView(.constant(true))
    }
}

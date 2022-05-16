//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o

import SwiftUI

struct AddBubbleNotesView: View {
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    private var bubbles:FetchedResults<Bubble>
    
    
    @State var searchString:String = ""
    @Binding var showBubbleNoteView:Bool
    @FocusState var isTyping:Bool
    
    init(_ showBubbleNoteView:Binding<Bool>) {
        _showBubbleNoteView = Binding(projectedValue: showBubbleNoteView)
    }
    
    private let size = CGSize(width: 250, height: 400)
    private let cornerRadius = CGFloat(24)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture { showBubbleNoteView = false }
            darkRoundedRect
                .overlay {
                    VStack {
                        topSpacer //pushes textfield down a little
                        textField
                            .onSubmit {
                                print("searchField \(searchString)")
                            }
                            .onAppear { isTyping = true }
                        List {
                            ForEach (bubbles) { bubble in
                                Text(bubble.note_)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color("deleteActionViewBackground"))
                        }
                        .listStyle(.plain)
                    }
                    .background  { backgroundView }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
        }
    }
    
    // MARK: - Legoes
    private var darkRoundedRect: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .frame(width: size.width, height: size.height)
            .foregroundColor(Color("searchFieldBackground"))
            .standardShadow(false)
    }
    
    private var textField: some View {
        TextField("Search/Add Note", text: $searchString)
            .focused($isTyping)
            .font(.title2)
            .padding()
    }
        
    private var backgroundView :some View {
        VStack {
            Spacer(minLength: 90)
            Color("deleteActionViewBackground")
        }
    }
    
    private var topSpacer: some View { Spacer(minLength: 14) }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddBubbleNotesView(.constant(true))
    }
}

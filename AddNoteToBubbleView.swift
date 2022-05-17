//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o

import SwiftUI

struct AddNoteToBubbleView: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var bubble:Bubble
    
    @State var textInput:String = ""
    @Binding var addBubbleNotesView_BubbleRank:Int?
    @FocusState var isTyping:Bool
    
    init(_ addBubbleNotesView_BubbleRank:Binding<Int?>) {
        print("init")
        _addBubbleNotesView_BubbleRank = Binding(projectedValue: addBubbleNotesView_BubbleRank)
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", addBubbleNotesView_BubbleRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        _bubble = StateObject(wrappedValue: bubble)
    }
    
    private let size = CGSize(width: 250, height: 400)
    private let cornerRadius = CGFloat(24)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture {
//                    bubble.note = textInput
                    PersistenceController.shared.save()
                    addBubbleNotesView_BubbleRank = nil
                }
            darkRoundedRect
                .overlay {
                    VStack {
                        topSpacer //pushes textfield down a little
                        textField
                            .onSubmit {
                                bubble.note = textInput
                                addBubbleNotesView_BubbleRank = nil
                                PersistenceController.shared.save()
                            }
                            .onAppear { isTyping = true }
                        List {
                            ForEach (0..<3) { index in
                                Text("\(index)")
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
        TextField("Search/Add Note", text: $textInput)
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
        AddNoteToBubbleView(.constant(65))
    }
}

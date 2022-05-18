//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o

import SwiftUI

struct BubbleNotesView: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var bubble:Bubble
    
    private let textInputLimit = 8
    @State private var textInput = ""
    @FocusState var keyboardVisible:Bool
    
    @Binding var addBubbleNotesView_BubbleRank:Int?
    
    init(_ addBubbleNotesView_BubbleRank:Binding<Int?>) {
        _addBubbleNotesView_BubbleRank = Binding(projectedValue: addBubbleNotesView_BubbleRank)
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", addBubbleNotesView_BubbleRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        _bubble = StateObject(wrappedValue: bubble)
        _textInput = State(initialValue: bubble.note_)
    }
    
    private let size = CGSize(width: 250, height: 400)
    private let cornerRadius = CGFloat(24)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture {
                    if textInput.isEmpty {
                        bubble.note_ = textInput
                        PersistenceController.shared.save()
                    }
                    addBubbleNotesView_BubbleRank = nil
                }
            darkRoundedRect
                .overlay {
                    VStack {
                        topSpacer //pushes textfield down a little
                        textField
                            .gesture(
                                DragGesture(minimumDistance: 10, coordinateSpace: .global)
                                    .onChanged { value in
                                        if value.translation.width < -20 {
                                            textInput = ""
                                        }
                                    }
                                    .onEnded { value in
                                        if textInput.isEmpty {
                                            UserFeedback.doubleHaptic(.rigid)
                                        }
                                    }
                            )
                            .overlay {
                                ZStack {
                                    Image(systemName: "plus.app")
                                        .font(.system(size: 72).weight(.light))
                                    Text("\(textInputLimit - textInput.count)")
                                        .font(.system(size: 18).weight(.bold))
                                        .offset(x: 15, y: 15)
                                }
                                .foregroundColor(textInput.count > 0 ? .blue : .gray)
                                .offset(x: 74, y: 0)
                                .onTapGesture {
                                    if textInput.count > 0 {
                                        saveTextInputAndDismiss()
                                    }
                                }
                                .onLongPressGesture {
                                    textInput = ""
                                    UserFeedback.doubleHaptic(.rigid)
                                }
                            }
                            .onSubmit {
                                addBubbleNotesView_BubbleRank = nil
                                PersistenceController.shared.save()
                            }
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
        .onAppear {
            delayExecution(.now() + 0.05) {
                withAnimation (.easeInOut(duration: 0.0)) { keyboardVisible = true }
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
        TextField("Add Note", text: $textInput)
        .font(.title2)
        .padding()
        .focused($keyboardVisible)
        .textInputAutocapitalization(.words)
        .onChange(of: self.textInput) {
            if $0.count > textInputLimit { textInput = String(textInput.prefix(textInputLimit)) }
        }
        .onSubmit { saveTextInputAndDismiss() }
    }
    
    private var backgroundView :some View {
        VStack {
            Spacer(minLength: 90)
            Color("deleteActionViewBackground")
        }
    }
    
    private var topSpacer: some View { Spacer(minLength: 14) }
    
    private func saveTextInputAndDismiss() {
        //save textInput to CoreData and dismiss BubbleNotesView
        bubble.note = textInput
        PersistenceController.shared.save()
        addBubbleNotesView_BubbleRank = nil
        UserFeedback.singleHaptic(.heavy)
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNotesView(.constant(65))
    }
}

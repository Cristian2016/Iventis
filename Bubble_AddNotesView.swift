//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o

import SwiftUI

struct Bubble_AddNotesView: View {
    @StateObject var bubble:Bubble
    @EnvironmentObject var viewModel:ViewModel
    
    private let textInputLimit = 8
    
    let initialNote:String
    @State private var textFieldString = ""
    @FocusState var keyboardVisible:Bool
    
    @Binding var addBubbleNotesView_BubbleRank:Int?
    
    init(_ addBubbleNotesView_BubbleRank:Binding<Int?>) {
        _addBubbleNotesView_BubbleRank = Binding(projectedValue: addBubbleNotesView_BubbleRank)
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", addBubbleNotesView_BubbleRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        _bubble = StateObject(wrappedValue: bubble)
        self.initialNote = bubble.note_
    }
    
    private let size = CGSize(width: 250, height: 400)
    private let cornerRadius = CGFloat(24)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture {
                    saveTextInputAndDismiss()
                    addBubbleNotesView_BubbleRank = nil //dismiss self
                }
            darkRoundedRect
                .overlay {
                    VStack {
                        topSpacer //pushes textfield down a little
                        textField
                            .padding(.leading)
                            .gesture(
                                DragGesture(minimumDistance: 15, coordinateSpace: .global)
                                    .onChanged {
                                        if $0.translation.width < -20 { textFieldString = "" }
                                    }
                                    .onEnded { _ in
                                        if textFieldString.isEmpty { UserFeedback.doubleHaptic(.rigid)
                                        }
                                    }
                            )
                            .overlay {
                                plusButton
                                .onTapGesture {
                                    if textFieldString.count > 0 {
                                        saveTextInputAndDismiss()
                                        addBubbleNotesView_BubbleRank = nil //dimiss self
                                    }
                                }
                                .onLongPressGesture {
                                    textFieldString = ""
                                    UserFeedback.doubleHaptic(.rigid)
                                }
                            }
                            .onSubmit {
                                saveTextInputAndDismiss()
                                addBubbleNotesView_BubbleRank = nil //dimiss self
                            }
                        List {
                            ForEach (bubble.history_.reversed()) { history in
                                Text("\(history.note ?? "No Note")")
                                    .font(.system(size: 23))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                            }
                            .onDelete { indexSet in
                                bubble.removeFromHistory(at: NSIndexSet(indexSet: indexSet))
                                PersistenceController.shared.save()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color("deleteActionViewBackground"))
                        }
                        .listStyle(.plain)
                        .environment(\.defaultMinListRowHeight, 10)
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
        TextField("Add Note", text: $textFieldString)
        .font(.title2)
        .padding()
        .focused($keyboardVisible)
        .textInputAutocapitalization(.words)
        .onChange(of: self.textFieldString) {
            if $0.count > textInputLimit { textFieldString = String(textFieldString.prefix(textInputLimit)) }
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
        if initialNote == textFieldString || textFieldString.isEmpty { return }
        
        viewModel.save(textFieldString, for: bubble)
        UserFeedback.singleHaptic(.heavy)
        
        PersistenceController.shared.save()
    }
        
    private var plusButton:some View {
        Image(systemName: "plus.app.fill")
            .background(Circle().fill(Color.white).padding())
            .font(.system(size: 72).weight(.light))
            .foregroundColor(textFieldString.count > 0 ? .blue : .gray)
            .overlay { remainingCharactersCounterView }
            .offset(x: 74, y: 0)
    }
    
    private var remainingCharactersCounterView:some View {
        Text("\(textInputLimit - textFieldString.count)")
            .font(.system(size: 18).weight(.bold))
            .foregroundColor(.white)
            .offset(x: 15, y: 15)
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        Bubble_AddNotesView(.constant(65))
    }
}

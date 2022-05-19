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
    @FetchRequest private var items:FetchedResults<BubbleSavedNote>
    
    private var filteredItems:[BubbleSavedNote] {
        if textFieldString.isEmpty { return Array(items) }
        let filtered = items.filter { history in
            history.note!.lowercased().contains(textFieldString.lowercased())
        }
        return Array(filtered)
    }
    
    private let textInputLimit = 9
    
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
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "bubble = %@", bubble)
        _items = FetchRequest(entity: BubbleSavedNote.entity(), sortDescriptors: [sort], predicate: predicate, animation: .default)
    }
    
    private let size = CGSize(width: 250, height: 420)
    private let cornerRadius = CGFloat(24)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture {
                    saveTextInput()
                    dismiss()
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
                                        saveTextInput()
                                        dismiss()
                                    }
                                }
                                .onLongPressGesture {
                                    textFieldString = ""
                                    UserFeedback.doubleHaptic(.rigid)
                                }
                            }
                            .onSubmit {
                                saveTextInput()
                                dismiss()
                            }
                        List {
                            ForEach (filteredItems) { item in
                                Text("\(item.note ?? "No Note")")
                                    .font(.system(size: 25))
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing], 4)
                                    .background( Rectangle().fill(item.note == bubble.note ? Color.black : .clear))
                                    .padding(.leading)
                                    .onTapGesture {
                                        UserFeedback.singleHaptic(.heavy)
                                        bubble.note = item.note
                                        try? PersistenceController.shared.viewContext.save()
                                        dismiss()
                                    }
                            }
                            .onDelete { viewModel.delete(filteredItems[$0.first!]) }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color("deleteActionViewBackground"))
                        }
                        .listStyle(.plain)
                        .environment(\.defaultMinListRowHeight, 8)
                    }
                    .background  { backgroundView }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
        }
        .ignoresSafeArea(.container, edges: .top)
        .padding(.top, 2)
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
        .onSubmit { saveTextInput() }
    }
    
    private var backgroundView :some View {
        VStack {
            Spacer(minLength: 90)
            Color("deleteActionViewBackground")
        }
    }
    
    private var topSpacer: some View { Spacer(minLength: 10) }
    
    private func saveTextInput() {
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
    
    private func dismiss() { addBubbleNotesView_BubbleRank = nil }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        Bubble_AddNotesView(.constant(65))
    }
}

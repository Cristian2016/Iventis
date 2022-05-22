//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o
///⚠️⚠️⚠️ do not use didSet or willSet on @State properties, because they don't work! use .onChange(of:perform:) instead!

import SwiftUI

struct BubbleStickyNotesList: View {
    let bubble:Bubble  /* ⚠️ do not use @StateObject bubble:Bubble! because each time Bubble.bubbleCell_Components update, bubble will emit and body will get recomputed each mother fucking second!!!  */
    let viewModel:ViewModel
    @FetchRequest private var items:FetchedResults<BubbleSavedNote>
    
    private var filteredItems:[BubbleSavedNote] {
        if textInput.isEmpty { return Array(items) }
        let filtered = items.filter { history in
            history.note!.lowercased().contains(textInput.lowercased())
        }
        return Array(filtered)
    }
    
    @State private var textInput = "" //willSet and didSet do not work anymore
    private let textInputLimit = 9
    private let textFieldPlaceholder = "Add/Search Note"
    
    let initialNote:String
    @FocusState var keyboardVisible:Bool
    
    @Binding var addBubbleNotesView_BubbleRank:Int?
    
    private let size = CGSize(width: 250, height: 420)
    private let cornerRadius = CGFloat(24)
    
    // MARK: -
    init(_ addBubbleNotesView_BubbleRank:Binding<Int?>, _ viewModel:ViewModel) {
        //setting rank to nil dismisses self
        _addBubbleNotesView_BubbleRank = Binding(projectedValue: addBubbleNotesView_BubbleRank)
        
        //set Bubble
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", addBubbleNotesView_BubbleRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        self.bubble = bubble
        
        //set initial note
        self.initialNote = bubble.note_
        
        //set viewModel
        self.viewModel = viewModel
        
        let sorts = [
//            NSSortDescriptor(key: "bubble", ascending: false), //⚠️ crashes for some reason..
            NSSortDescriptor(key: "date", ascending: false)
        ]
        _items = FetchRequest(entity: BubbleSavedNote.entity(), sortDescriptors: sorts, predicate: nil, animation: .default)
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .onTapGesture {
                    saveTextInput()
                    dismiss()
                }
            darkRoundedBackground
                .overlay {
                    ZStack {
                        VStack {
                            Spacer(minLength: 10)
                            textField
                                .padding(.leading)
                                .gesture(
                                    DragGesture(minimumDistance: 15, coordinateSpace: .global)
                                        .onChanged {
                                            if $0.translation.width < -20 { textInput = "" }
                                        }
                                        .onEnded { _ in
                                            if textInput.isEmpty { UserFeedback.doubleHaptic(.rigid)
                                            }
                                        }
                                )
                                .onSubmit {
                                    saveTextInput()
                                    dismiss()
                                }
                            List {
                                //⚠️ this little shit prevents app from crashing
                                //when textInput is dragged around on screen
                                if filteredItems.isEmpty { emptyListAlert }
                                
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
                                            bubble.isNoteHidden = false
                                            try? PersistenceController.shared.viewContext.save()
                                            dismiss()
                                        }
                                }
                                .onDelete { viewModel.delete(filteredItems[$0.first!]) }
                                .listRowBackground(Color("deleteActionViewBackground"))
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 8)
                        }
                        .background  { backgroundView }
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        plusButton
                    }
                    
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
    
    // MARK: - Lego
    private var emptyListAlert: some View {
        HStack {
            Spacer()
            VStack (alignment: .leading) {
                Text("Empty List")
                    .font(.system(size: 30))
                Text("No Matches")
                    .font(.system(size: 26))
                    .background(Color.red)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .background(Color("deleteActionViewBackground").padding(-100))
        .offset(y: 50)
    }
    
    private var darkRoundedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .frame(width: size.width, height: size.height)
            .foregroundColor(Color("searchFieldBackground"))
            .standardShadow(false)
    }
    
    ///I use this because I couldn't find a way to center text placeholder on Text Field
    private var placeholder: some View {
            Text(textFieldPlaceholder)
            .font(.title2)
            .foregroundColor(.lightGray)
    }
    
    private var textField: some View {
        ZStack {
            if textInput.isEmpty { placeholder }
            TextField("", text: $textInput)
        }
        
        .font(.title2)
        .padding()
        .focused($keyboardVisible)
        .textInputAutocapitalization(.words)
        .onChange(of: self.textInput) {
            if $0.count > textInputLimit { textInput = String(textInput.prefix(textInputLimit)) }
        }
    }
    
    private var backgroundView :some View {
        VStack {
            Spacer(minLength: 90)
            Color("deleteActionViewBackground")
        }
    }
    
    @ViewBuilder
    private var plusButton:some View {
        if !textInput.isEmpty {
            Push(.topRight) {
                Image(systemName: "plus.app.fill")
                    .background(Circle().fill(Color.white).padding())
                    .font(.system(size: 72).weight(.light))
                    .foregroundColor(textInput.count > 0 ? .blue : .gray)
                    .overlay { remainingCharactersCounterView }
                //gestures
                    .onTapGesture {
                        if textInput.count > 0 {
                            saveTextInput()
                            dismiss()
                        }
                    }
                    .onLongPressGesture {
                        textInput = ""
                        UserFeedback.doubleHaptic(.rigid)
                    }
            }
        }
    }
    
    private var remainingCharactersCounterView:some View {
        Text("\(textInputLimit - textInput.count)")
            .font(.system(size: 18).weight(.bold))
            .foregroundColor(.white)
            .offset(x: 15, y: 15)
    }
    
    // MARK: -
    private func dismiss() { addBubbleNotesView_BubbleRank = nil }
    
    private func saveTextInput() {
        if initialNote == textInput || textInput.isEmpty { return }
        
        viewModel.save(textInput, for: bubble)
        UserFeedback.singleHaptic(.heavy)
        
        PersistenceController.shared.save()
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleStickyNotesList(.constant(65), ViewModel())
    }
}

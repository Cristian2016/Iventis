//
//  BubbleNoteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.05.2022.
//  searchable modifier https://www.youtube.com/watch?v=5soAxQCF29o
//⚠️ do not use didSet or willSet on @State properties, because they don't work! use .onChange(of:perform:) instead!
//⚠️ cell.height:
// set both 1. environment(\.defaultMinListRowHeight) and 2. cell.frame
//1 ⚠️ this little shit prevents app from crashing when textInput is dragged around on screen

import SwiftUI

struct BubbleStickyNotesList: View {
    let bubble:Bubble  /* ⚠️ do not use @StateObject bubble:Bubble! because each time Bubble.bubbleCell_Components update, bubble will emit and body will get recomputed each mother fucking second!!!  */
    @EnvironmentObject private var viewModel:ViewModel
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
    private let line0 = "No Matches"
    private let line1 = Text("Tap \(Image(systemName: "plus.app.fill")) to Save Note")
        .font(.system(size: 23))
    private let line2 = Text("Tap Hold \(Image(systemName: "plus.app.fill")) to Delete").font(.system(size: 21))
    private let line3 = Text("Empty Notes will not be saved").font(.system(size: 21))
    
    let initialNote:String
    @FocusState var keyboardVisible:Bool
    @Binding var showAddNotes_bRank:Int?
    
    private let size = CGSize(width: 250, height: 412)
    private let cornerRadius = CGFloat(24)
    
    // MARK: -
    init(_ stickyNotesList_bRank:Binding<Int?>) {
        //set Bubble
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", stickyNotesList_bRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        self.bubble = bubble
        
        //set initial note
        self.initialNote = bubble.note_
        
        let sorts = [
//            NSSortDescriptor(key: "bubble", ascending: false), //⚠️ crashes for some reason..
            NSSortDescriptor(key: "date", ascending: false)
        ]
        _items = FetchRequest(entity: BubbleSavedNote.entity(), sortDescriptors: sorts, predicate: nil, animation: .default)
        _showAddNotes_bRank = Binding(projectedValue: stickyNotesList_bRank)
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            screenBackground
            darkRoundedBackground
                .overlay {
                    VStack {
                        Spacer(minLength: 10)
                        textField
                        //layout
                            .padding(.leading)
                        //gestures
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
                            if filteredItems.isEmpty { emptyListAlert } //1
                            
                            ForEach (filteredItems) { cell($0) }
                            //gestures
                                .onDelete { viewModel.delete(filteredItems[$0.first!]) }
                            //
//                                .listRowBackground(Color("deleteActionViewBackground"))
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .environment(\.defaultMinListRowHeight, 8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    plusButton
                }
        }
        .offset(y:10)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            delayExecution(.now() + 0.05) {
                withAnimation (.easeInOut(duration: 0.0)) { keyboardVisible = true }
            }
        }
    }
    
    // MARK: - Lego
    private func cell(_ item:BubbleSavedNote) -> some View {
        Text("\(item.note ?? "No Note")")
        //text
            .font(.system(size: 25))
            .background( Rectangle()
                .fill(item.note == bubble.note ? Color.selectionGray : .clear)
            )
        //layout
            .padding([.leading], 10)
            .frame(height: 15)
        //gestures
            .onTapGesture {
                UserFeedback.singleHaptic(.heavy)
                bubble.note = item.note
                bubble.isNoteHidden = false
                try? PersistenceController.shared.viewContext.save()
                dismiss()
            }
    }
    
    private var emptyListAlert: some View {
        HStack {
            Spacer()
            VStack (alignment: .leading, spacing: 4) {
                Text(line0)
                    .font(.system(size: 30))
                    .background(Color.red)
                if noteIsValid { SomeView(entry: $textInput) }
                else { line3 }
            }
            Spacer()
        }
        .foregroundColor(.white)
        .background(Color("deleteActionViewBackground").padding(-250))
        .offset(y: 50)
    }
    
    private var screenBackground: some View {
        Color.background.opacity(0.5)
            .onTapGesture {
                if noteIsValid { saveTextInput() }
                dismiss()
            }
    }
    
    private var darkRoundedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color("deleteActionViewBackground"))
            .frame(width: size.width, height: size.height)
            .standardShadow(false)
    }
    
    ///I use this because I couldn't find a way to center text placeholder on Text Field
    private var placeholder: some View {
            Text(textFieldPlaceholder)
            .font(.system(size: 26))
            .foregroundColor(.lightGray)
    }
    
    private var textField: some View {
        ZStack {
            if textInput.isEmpty { placeholder }
            TextField("", text: $textInput)
        }
        .font(.system(size: 24))
        .foregroundColor(.white)
        .padding()
        .focused($keyboardVisible)
        .textInputAutocapitalization(.words)
        .onChange(of: self.textInput) {
            if $0.count > textInputLimit { textInput = String(textInput.prefix(textInputLimit)) }
        }
    }
    
    ///tap plus to save note or long press to delete note
    @ViewBuilder
    private var plusButton:some View {
        if !textInput.isEmpty && noteIsValid {
            Push(.topRight) {
                Image(systemName: "plus.app")
                    .font(.system(size: 72).weight(.thin))
                    .foregroundColor(textInput.count > 0 ? .white : .gray)
                    .overlay { remainingCharactersCounterView }
                //gestures
                    .onTapGesture {
                        if noteIsValid {
                            saveTextInput()
                            dismiss()
                        }
                    }
                    .highPriorityGesture (
                        LongPressGesture(minimumDuration: 0.3)
                            .onEnded { _ in
                                textInput = ""
                                UserFeedback.doubleHaptic(.rigid)
                            }
                    )
            }
        }
    }
    
    private var noteIsValid: Bool {
        let condition = !textInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        
        if textInput.count > 0 && condition {
            return true
        }
        
        return false
    }
    
    private var remainingCharactersCounterView:some View {
        Text("\(textInputLimit - textInput.count)")
            .font(.system(size: 18).weight(.medium))
            .foregroundColor(.white)
            .offset(x: 15, y: 15)
    }
    
    // MARK: -
    private func dismiss() { showAddNotes_bRank = nil }
    
    private func saveTextInput() {
        if initialNote == textInput || textInput.isEmpty { return }
        
        viewModel.save(textInput, for: bubble)
        UserFeedback.singleHaptic(.heavy)
        
        PersistenceController.shared.save()
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleStickyNotesList(.constant(0))
    }
}

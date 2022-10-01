//
//  NotesList.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.06.2022.
//

import SwiftUI

struct StickyNoteList: View {
    var stickyNotes:[String]
    
    let textInputLimit:Int
    let initialNote:String
    
    private var filteredStickyNotes:[String] {
        if textFieldText.isEmpty { return stickyNotes }
        let filtered = stickyNotes.filter { $0.lowercased().contains(textFieldText.lowercased()) }
        return filtered
    }
    
    @State private var textFieldText = ""
    @FocusState private var keyboardVisible:Bool
    
    ///note is not valid: "" or "       "
    private var stickyNoteIsValid: Bool {
        //only empty space ex: "    "
        let onlyEmptySpace = textFieldText.isAllEmptySpace
        
        if !textFieldText.isEmpty && !onlyEmptySpace { return true }
        if initialNote == textFieldText { return false }
        
        return false
    }
    
    // MARK: - Metrics
    private let size = CGSize(width: 220, height: 382)
    private let cornerRadius = CGFloat(24)
    
    private let textFieldPlaceholder = "Search/Add Note"
    private let line0 = "No Matches"
    private let line1 = Text("Tap \(Image(systemName: "plus.app.fill")) to Save Note")
        .font(.system(size: 23))
    private let line2 = Text("Tap Hold \(Image(systemName: "plus.app.fill")) to Delete").font(.system(size: 21))
    private let line3 = Text("Empty Notes will not be saved").font(.system(size: 21))
    
    // MARK: - Intents
    private func deleteTextInput() {
        UserFeedback.doubleHaptic(.rigid)
        textFieldText = ""
    }
    
    private func saveNoteAndDismiss() {
        saveNoteToCoredata(textFieldText)
        
        //apparently it crashes without a bit of delay
        delayExecution(.now() + 0.1) {
            self.dismiss()
            PersistenceController.shared.save()
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            screenBackground
                .onTapGesture {
                    if stickyNoteIsValid { saveNoteAndDismiss() }
                    else { dismiss() }
                }
                .gesture (
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in deleteTextInput() }
                )
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { _ in deleteTextInput() }
                )
            VStack {
                darkRoundedBackground
                    .overlay {
                        VStack {
                            Spacer(minLength: 10)
                            textField
                                .overlay { remainingCharactersCounterView }
                                .onSubmit { saveNoteAndDismiss() } //user tapped Enter key
                            List {
                                if filteredStickyNotes.isEmpty { emptyListAlert } //1
                                
                                ForEach (filteredStickyNotes, id: \.self) { cell($0) }
                                .onDelete { deleteStickyNote($0.first!) }
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                Spacer()
            }
            .padding([.top])
            .padding([.top])
            .padding([.top])
        }
        .onAppear { withAnimation (.easeInOut) { keyboardVisible = true } }
    }
    
    // MARK: - Lego
    private var emptyListAlert: some View {
        HStack {
            Spacer()
            VStack (alignment: .leading, spacing: 4) {
                Text(line0)
                    .font(.system(size: 30))
                    .background(Color.red)
                if stickyNoteIsValid { Note_InfoView() }
                else { EmptyNote_InfoView() }
            }
            Spacer()
        }
        .foregroundColor(.white)
        .background(Color("deleteActionViewBackground").padding(-250))
    }
    
    private var screenBackground: some View {
        Color.alertScreenBackground
            .opacity(0.9)
            .ignoresSafeArea()
    }
    
    private var darkRoundedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.background3)
            .frame(width: size.width, height: size.height)
            .standardShadow(false)
    }
    
    private var textField: some View {
        ZStack {
            if textFieldText.isEmpty { placeholder }
            TextField("", text: $textFieldText)
        }
        .font(.system(size: 24))
        .foregroundColor(.background2)
        .padding()
        .focused($keyboardVisible)
        .textInputAutocapitalization(.words)
        .onChange(of: self.textFieldText) {
            if $0.count > textInputLimit { textFieldText = String(textFieldText.prefix(textInputLimit)) }
        }
    }
    
    private var placeholder: some View {
            Text(textFieldPlaceholder)
            .font(.system(size: 23))
            .foregroundColor(.lightGray)
    }
    
    private func cell(_ item:String) -> some View {
        HStack {
            Text("\(item)").layoutPriority(1)
                .font(.system(size: 25))
                .background(
                    Rectangle()
                        .fill(item == initialNote ? Color.selectionGray : .clear)
                )
            Rectangle().fill(Color.white.opacity(0.001))
        }
        //layout
            .padding([.leading], 10)
            .frame(height: 15)
        //gestures
            .onTapGesture {
                UserFeedback.singleHaptic(.heavy)
                selectExistingNote(item) //will be handled externally
                try? PersistenceController.shared.viewContext.save()
                dismiss()
            }
    }
    
    @ViewBuilder
    private var remainingCharactersCounterView:some View {
        if !textFieldText.isEmpty {
            HStack {
                Spacer()
                Text("\(textInputLimit - textFieldText.count)")
                    .font(.system(size: 18).weight(.medium))
                    .foregroundColor(.background2)
            }
            .padding(.trailing)
            .offset(y: 22)
        }
    }
    
    //External Actions
    //each View using this view has different code
    //implemented within closures
    var dismiss: () -> Void
    var deleteStickyNote: (IndexSet.Element?) -> Void
    
    var saveNoteToCoredata: (String) -> Void
    var selectExistingNote: (String) -> Void
}

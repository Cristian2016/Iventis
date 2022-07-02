//
//  NotesList.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.06.2022.
//

import SwiftUI

struct NotesList: View {
    var notes:[String]
    let textInputLimit:Int
    let initialNote:String
    
    private var filteredItems:[String] {
        if textInput.isEmpty { return Array(notes) }
        let filtered = notes.filter {
            $0.lowercased().contains(textInput.lowercased())
        }
        return filtered //Array(Set to avoid duplicates
    }
    
    private let size = CGSize(width: 220, height: 382)
    private let cornerRadius = CGFloat(24)
    
    @State private var textInput = ""
    @FocusState private var keyboardVisible:Bool
    
    private let textFieldPlaceholder = "Search/Add Note"
    private let line0 = "No Matches"
    private let line1 = Text("Tap \(Image(systemName: "plus.app.fill")) to Save Note")
        .font(.system(size: 23))
    private let line2 = Text("Tap Hold \(Image(systemName: "plus.app.fill")) to Delete").font(.system(size: 21))
    private let line3 = Text("Empty Notes will not be saved").font(.system(size: 21))
    
    private func deleteTextInput() {
        UserFeedback.doubleHaptic(.rigid)
        textInput = ""
    }
    
    private func dismiss(closure: () ->()) {
        closure()
    }
    
    private func saveTextInputAndDismiss() {
        saveNoteToCoredata(textInput)
        dismiss()
        PersistenceController.shared.save()
    }
    
    ///if "" or "       " note is not valid
    private var noteIsValid: Bool {
        let allWhiteSpaces = textInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        if !textInput.isEmpty && !allWhiteSpaces { return true }
        if initialNote == textInput { return false }
        
        return false
    }
    
    var body: some View {
        ZStack {
            screenBackground
                .onTapGesture {
                    if noteIsValid { saveTextInputAndDismiss() }
                }
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { _ in deleteTextInput() }
                )
                .highPriorityGesture (
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in deleteTextInput() }
                )
            VStack {
                darkRoundedBackground
                    .overlay {
                        VStack {
                            Spacer(minLength: 10)
                            textField
                                .onSubmit { saveTextInputAndDismiss() }
                                .overlay {
                                    if !textInput.isEmpty {
                                        HStack {
                                            Spacer()
                                            remainingCharactersCounterView
                                        }
                                        .padding(.trailing)
                                        .offset(y: 22)
                                    }
                                }
                            List {
                                if filteredItems.isEmpty { emptyListAlert } //1
                                
                                ForEach (filteredItems, id: \.self) { item in
                                    cell(item)
                                }
                                .onDelete { deleteItem($0.first!) }
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                Spacer()
            }
            .padding([.top], 45)
        }
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
            VStack (alignment: .leading, spacing: 4) {
                Text(line0)
                    .font(.system(size: 30))
                    .background(Color.red)
                if noteIsValid { Note_InfoView() }
                else { EmptyNote_InfoView() }
            }
            Spacer()
        }
        .foregroundColor(.white)
        .background(Color("deleteActionViewBackground").padding(-250))
    }
    
    private var screenBackground: some View {
        Color("notesListScreenBackground")
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
            if textInput.isEmpty { placeholder }
            TextField("", text: $textInput)
        }
        .font(.system(size: 24))
        .foregroundColor(.background2)
        .padding()
        .focused($keyboardVisible)
        .textInputAutocapitalization(.words)
        .onChange(of: self.textInput) {
            if $0.count > textInputLimit { textInput = String(textInput.prefix(textInputLimit)) }
        }
    }
    
    private var placeholder: some View {
            Text(textFieldPlaceholder)
            .font(.system(size: 23))
            .foregroundColor(.lightGray)
    }
    
    private func cell(_ item:String) -> some View {
        Text("\(item)")
        //text
            .font(.system(size: 25))
            .background( Rectangle()
                .fill(item == initialNote ? Color.selectionGray : .clear)
            )
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
    
    private var remainingCharactersCounterView:some View {
        Text("\(textInputLimit - textInput.count)")
            .font(.system(size: 18).weight(.medium))
            .foregroundColor(.background2)
    }
    
    //External Actions
    //each View using this view has different code
    //implemented within closures
    var dismiss: () -> Void
    var deleteItem: (IndexSet.Element?) -> Void
    
    var saveNoteToCoredata: (String) -> Void
    var selectExistingNote: (String) -> Void
}

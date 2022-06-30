//
//  NotesList.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.06.2022.
//

import SwiftUI

struct NotesList: View {
    @State var items:[String]
    var filteredItems:[String] {
        if textInput.isEmpty { return Array(items) }
        let filtered = items.filter {
            $0.lowercased().contains(textInput.lowercased())
        }
        return Array(filtered)
    }
    
    let size = CGSize(width: 220, height: 382)
    let cornerRadius = CGFloat(24)
    
    @FocusState var keyboardVisible:Bool
    
    let textInputLimit:Int
    let textFieldPlaceholder = "Search/Add Note"
    let line0 = "No Matches"
    let line1 = Text("Tap \(Image(systemName: "plus.app.fill")) to Save Note")
        .font(.system(size: 23))
    let line2 = Text("Tap Hold \(Image(systemName: "plus.app.fill")) to Delete").font(.system(size: 21))
    let line3 = Text("Empty Notes will not be saved").font(.system(size: 21))
    
    func deleteTextInput() {
        UserFeedback.doubleHaptic(.rigid)
        textInput = ""
    }
    
    func saveTextInputAndDismiss() {
        guard !textInput.isEmpty else { return }
        
        saveNoteToCoredata(textInput)
        dismiss()
    }
    
    func dismiss(closure: () ->()) {
        closure()
    }
    
    func saveTextInput() {
        if initialNote == textInput || textInput.isEmpty { return }
        
        saveNoteToCoredata(textInput)
        
        UserFeedback.singleHaptic(.heavy)
        PersistenceController.shared.save()
    }
    
    var noteIsValid: Bool {
        let condition = !textInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        
        if textInput.count > 0 && condition {
            return true
        }
        
        return false
    }
    
    let initialNote:String
    @State var textInput = ""
    
    var body: some View {
        ZStack {
            screenBackground
                .onTapGesture {
                    if noteIsValid { saveTextInput() }
                    dismiss()
                }
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { _ in deleteTextInput() }
                )
                .highPriorityGesture (
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in deleteTextInput() }
                )
            darkRoundedBackground
                .overlay {
                    VStack {
                        Spacer(minLength: 10)
                        textField.onSubmit { saveTextInputAndDismiss() }
                        List {
                            if filteredItems.isEmpty {
//                                emptyListAlert
                                
                            } //1
                            
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
        }
        .onAppear {
            delayExecution(.now() + 0.05) {
                withAnimation (.easeInOut(duration: 0.0)) { keyboardVisible = true }
            }
        }
    }
    
    // MARK: - Lego
    var screenBackground: some View {
        Color("notesListScreenBackground").opacity(0.9)
            .ignoresSafeArea()
    }
    
    var darkRoundedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.background3)
            .frame(width: size.width, height: size.height)
            .standardShadow(false)
    }
    
    var textField: some View {
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
    
    var placeholder: some View {
            Text(textFieldPlaceholder)
            .font(.system(size: 23))
            .foregroundColor(.lightGray)
    }
    
    func cell(_ item:String) -> some View {
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
    
    //External Actions
    var dismiss: () -> Void
    var deleteItem: (IndexSet.Element?) -> Void
    
    var saveNoteToCoredata: (String) -> Void
    var selectExistingNote: (String) -> Void
}

//struct NotesList_Previews: PreviewProvider {
//    static var previews: some View {
//        NotesList()
//    }
//}

//
//  NotesList.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.06.2022.
//1 make keyboard visible on iPhone only if it's portrait mode, in landscape hide it
//2 prevents ScrollView tap to dismiss NotesList and also allows user to tap on a note. tap is an empty gesture

import SwiftUI
import MyPackage

struct NotesOverlay: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var textFieldText = ""
    @FocusState private var isKeyboardVisible:Bool
    
    //MARK: - Init Parameters
    var stickyNotes:[String]
    let textInputLimit:Int
    let initialNote:String
    var bubble:Bubble?

    var deleteStickyNote: (String) -> Void
    var selectExistingNote: (String) -> Void
    var kind: NotesOverlay.Underlabel.Kind
    
    //MARK: -
    private var filteredStickyNotes:[String] {
        if textFieldText.isEmpty { return stickyNotes }
        let filtered = stickyNotes.filter { $0.lowercased().contains(textFieldText.lowercased()) }
        return filtered
    }
    
    ///note is not valid: "" or "       "
    private var stickyNoteIsValid: Bool {
        //only empty space ex: "    "
        let onlyEmptySpace = textFieldText.isAllEmptySpace
        
        if !textFieldText.isEmpty && !onlyEmptySpace { return true }
        if initialNote == textFieldText { return false }
        
        return false
    }
    
    // MARK: - Intents
    private func saveNoteAndDismiss() {
        guard stickyNoteIsValid else {
            UserFeedback.singleHaptic(.light)
            dismiss()
            return
        }
        
        UserFeedback.singleHaptic(.heavy)
        dismiss()
    }
    
    private func deleteTextFieldText() {
        UserFeedback.doubleHaptic(.rigid)
        textFieldText = ""
    }
    
    //deleteTextFieldText
    private var dragGesture:some Gesture {
        DragGesture(minimumDistance: 50).onEnded { _ in deleteTextFieldText() }
    }
    
    private func dismiss() {
        HintOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
        
        withAnimation(.bouncy(duration: 0.15)) {
            viewModel.notes_Bubble = nil
//            viewModel.notesPair(.hide)
        }
    }
    
    // MARK: - Body
    var body: some View {
        let isPortrait = verticalSizeClass == .regular
        
        ZStack {
            Background(.dark(.Opacity.overlay))
                .onTapGesture { dismiss() }
                .overlay(alignment: .top) { ControlOverlay.BubbleLabel(.hasBubble(bubble)) }
            
            OverlayScrollView {
                VStack(spacing: 0) {
                    textField
                        .onSubmit { saveNoteAndDismiss() }
                        .overlay(alignment: .bottom) {
                            //show only if no notes appear in the table (empty table)
                            if filteredStickyNotes.isEmpty { Separator() }
                        }
                    ScrollView {
                        let columnsCount = verticalSizeClass == .compact ? 4 : 2
                        let columns = Array(repeating: GridItem(spacing: 1), count: columnsCount)
                        
                        if !filteredStickyNotes.isEmpty {
                            LazyVGrid(columns: columns, spacing: 1) {
                                ForEach (filteredStickyNotes, id: \.self) { stickyNote in
                                    Color.background
                                        .overlay(alignment: .leading) { text(stickyNote) }
                                        .overlay(alignment: .topTrailing) { checkmark(stickyNote) }
                                        .onTapGesture { select(stickyNote) }
                                        .onLongPressGesture { delete(stickyNote) }
                                }
                                .frame(height: 46)
                            }
                            .font(.system(size: 26))
                        } else {
                            InfoView2()
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.init(top: 0, leading: 8, bottom: 8, trailing: 8))
                    .frame(idealHeight: isPortrait ? 294 : 280, maxHeight: isPortrait ? 294 : 280) //⚠️
                }
                .gesture(dragGesture)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: isPortrait ? 360 : 700)
                .compositingGroup()
                .standardShadow()
                .onChange(of: textFieldText, initial: false) { viewModel.stickyNoteText = $1 }
                // .onAppear { keyboardVisible =  true }
            } action: {
                dismiss()
            }
        }
    }
    
    // MARK: -
    private func delete(_ stickyNote:String) {
        UserFeedback.singleHaptic(.heavy)
        deleteStickyNote(stickyNote)
    }
    
    private func select(_ stickyNote:String) {
        UserFeedback.singleHaptic(.heavy)
        viewModel.userChoseNoteInTheList = true
        selectExistingNote(stickyNote) //will be handled externally
        dismiss()
    }
    
    // MARK: - Lego
    @ViewBuilder
    private func checkmark(_ stickyNote:String) -> some View {
        let isSameAsInitialNote = stickyNote == initialNote
        
        if isSameAsInitialNote {
            Label("Selected Note", systemImage: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.green)
                .labelStyle(.iconOnly)
                .padding([.top, .trailing], 2)
                .allowsHitTesting(false)
        }
    }
    
    private func text(_ stickyNote:String) -> some View {
        Text(stickyNote)
            .allowsHitTesting(false)
            .padding(.leading, 4)
    }
    
    private var textField: some View {
        TextField(kind == .bubble ? "Enter Tracker Name" : "Enter Lap Note", text: $textFieldText)
            .foregroundStyle(.primary)
            .font(.system(size: 26))
            .multilineTextAlignment(.center)
            .focused($isKeyboardVisible)
            .textInputAutocapitalization(.words)
            .overlay(alignment: .trailingFirstTextBaseline) { charactersCounterLabel }
            .onChange(of: textFieldText) {
                if $1.count > textInputLimit {
                    textFieldText = String(textFieldText.prefix(textInputLimit))
                }
            }
            .frame(height: .Overlay.displayHeight - 20)
        //            .onTapGesture {
        //                if !isKeyboardVisible { isKeyboardVisible = true }
        //            }
    }
    
    @ViewBuilder
    private var charactersCounterLabel:some View {
        if !textFieldText.isEmpty {
            Text("\(textInputLimit - textFieldText.count)")
                .font(.system(size: 20).weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.trailing)
        }
    }
}

extension NotesOverlay {
    struct Underlabel:View {
        let kind:Kind
        
        var body: some View {
            let title = kind == .bubble ? "Bubble" : "Pair"
            return Text("\(title) Notes")
                .foregroundStyle(.secondary)
                .font(.system(size: 14).italic())
                .offset(y: 4)
        }
        
        enum Kind {
            case bubble
            case pair
        }
    }
}

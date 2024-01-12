//
//  LapNotesOverlay1.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 22.01.2024.
//

import SwiftUI
import MyPackage

struct LapNotesOverlay1: View {
    let pair:Pair
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var notes:[PairSavedNote]
    
    @State private var textInput = "" //willSet and didSet do not work anymore
    @Environment(Secretary.self) private var secretary
    
    private var stickyNoteIsValid: Bool {
        //only empty space ex: "    "
        let onlyEmptySpace = textInput.isAllEmptySpace
        
        if !textInput.isEmpty && !onlyEmptySpace { return true }
        if initialNote == textInput { return false }
        
        return false
    }
    
    private let textInputLimit = 12
    
    let initialNote:String
    @FocusState var isKeyboardVisible:Bool
    private var bubble:Bubble?
    
    // MARK: -
    init?(_ tuple:(Pair?, [PairSavedNote])?) {
        guard let tuple = tuple else { return nil }
        guard let pair = tuple.0 else { return nil }
        
        self.pair = pair
        self.initialNote = pair.note_
        _notes = State(initialValue: tuple.1)
    }
    
    // MARK: -
    func deleteTextInput() {
        UserFeedback.doubleHaptic(.rigid)
        textInput = ""
    }
    
    var swipeToDeleteTextInput: some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { _ in deleteTextInput() }
    }
    
    private var textField: some View {
        TextField("Enter Lap Note", text: $textInput)
            .foregroundStyle(.primary)
            .font(.system(size: 26))
            .multilineTextAlignment(.center)
            .focused($isKeyboardVisible)
            .textInputAutocapitalization(.words)
            .overlay(alignment: .trailingFirstTextBaseline) { charactersCounterLabel }
            .onChange(of: textInput) {
                if $1.count > textInputLimit {
                    textInput = String(textInput.prefix(textInputLimit))
                }
            }
            .frame(height: .Overlay.displayHeight - 20)
        //            .onTapGesture {
        //                if !isKeyboardVisible { isKeyboardVisible = true }
        //            }
    }
    
    @ViewBuilder
    private var charactersCounterLabel:some View {
        if !textInput.isEmpty {
            Text("\(textInputLimit - textInput.count)")
                .font(.system(size: 20).weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.trailing)
        }
    }
    
    private var filteredStickyNotes:[String] {
        if textInput.isEmpty { return notes.compactMap(\.note) }
        let filtered = notes.compactMap(\.note).filter { $0.lowercased().contains(textInput.lowercased()) }
        return filtered
    }
    
    @ViewBuilder
    private func checkmark(_ stickyNote:String) -> some View {
        let isSameAsInitialNote = stickyNote == initialNote
        
        if isSameAsInitialNote {
            Label("Selected Note", systemImage: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.green)
                .labelStyle(.iconOnly)
        }
    }
    
    private func deleteTextFieldText() {
        UserFeedback.doubleHaptic(.rigid)
        textInput = ""
    }
    
    private var dragGesture:some Gesture {
        DragGesture(minimumDistance: 50).onEnded { _ in deleteTextFieldText() }
    }
    
    private func userTaps(_ note:PairSavedNote) {
        viewModel.userChoseNoteInTheList = true
        viewModel.selectExisting(note, initialNote, pair)
        dismiss()
    }
    
    // MARK: -
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
                                ForEach (notes) { note in
                                    if let string = note.note {
                                        Color.background
                                            .overlay(alignment: .leading) {
                                                HStack {
                                                    Text(string)
                                                    checkmark(string)
                                                }
                                                .padding(.leading, 4)
                                            }
                                            .onTapGesture {
                                                userTaps(note)
                                            }
                                            .onLongPressGesture {
                                                withAnimation(.bouncy) {
                                                    if let index = notes.firstIndex(of: note) {
                                                        notes.remove(at: index)
                                                    }
                                                }
                                                viewModel.deletePairNote(note)
                                            }
                                    }
                                }
                                .frame(height: 46)
                            }
                            .font(.system(size: 26))
                        } else {
//                            InfoView2()
                            emptyView
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
                .onChange(of: textInput, initial: false) { viewModel.stickyNoteText = $1 }
                // .onAppear { keyboardVisible =  true }
            } action: {
                dismiss()
            }
        }
        .onDisappear {
            if viewModel.userChoseNoteInTheList {
                viewModel.userChoseNoteInTheList = false
                viewModel.stickyNoteText = ""
                return
            }
            if !viewModel.stickyNoteText.isEmpty {
                saveNoteToCoreData(viewModel.stickyNoteText, for: pair)
                viewModel.stickyNoteText = ""
                viewModel.pairNotes(.hide)
            }
        }
//        .task {
//            execute(after: 3, mainQueue: false) {
//                PersistenceController.shared.bContext.perform {
//                    let request = PairSavedNote.fetchRequest()
//                    if let notes = try? PersistenceController.shared.bContext.fetch(request) {
//                        let thisBubbleBucket =
//                        notes.filter {
//                            $0.bubble?.rank == pair.session?.bubble?.rank
//                        }
//                        
//                        let otherBucket =
//                        notes.filter {
//                            $0.bubble?.rank != pair.session?.bubble?.rank
//                        }
//                        
//                        let sortedNotes = thisBubbleBucket + otherBucket
//                        print(sortedNotes.compactMap({
//                            $0.bubble?.color
//                        }))
//                    }
//                }
//            }
//        }
    }
    
    private func saveNoteAndDismiss() {
        guard stickyNoteIsValid else {
            UserFeedback.singleHaptic(.light)
            dismiss()
            return
        }
        
        UserFeedback.singleHaptic(.heavy)
        dismiss()
    }
    
    private func moveNoteAtTheBegginingOfTheList(for note:String) {
        //don't move note if it's on top already
        guard
            notes.first?.note != note        else { return }
        
        //move selected note on top of the list
        if let pairSavedNote = notes.filter({ $0.note == note }).first {
            let objID = pairSavedNote.objectID
            
            PersistenceController.shared.bContext.perform {
                let bPairSavedNote = PersistenceController.shared.grabObj(objID) as? PairSavedNote
                bPairSavedNote?.date = Date()
                //no need to save bContext, because selectExistingNote will save anyway :)
            }
            return
        }
        
        if let pairSavedNote = notes.filter({ $0.note == note }).first {
            let objID = pairSavedNote.objectID
            
            PersistenceController.shared.bContext.perform {
                let bPairSavedNote = PersistenceController.shared.grabObj(objID) as? PairSavedNote
                bPairSavedNote?.date = Date()
                //no need to save bContext, because selectExistingNote will save anyway :)
            }
        }
    }
    
    ///when user selects an existing note instead of typing in a new note
    private func selectExitingNote(_ note:String) {
        DispatchQueue.global().async {
            var trimmedNote = note
            trimmedNote.removeWhiteSpaceAtBothEnds()
            
            if initialNote == trimmedNote { return }
            
            UserFeedback.singleHaptic(.heavy)
            
            self.moveNoteAtTheBegginingOfTheList(for: note)
            
            let bContext = PersistenceController.shared.bContext
            let objID = pair.objectID
            
            bContext.perform {
                let thisPair = PersistenceController.shared.grabObj(objID) as! Pair
                
                //set pair.note and show note
                thisPair.note = trimmedNote
                thisPair.isNoteHidden = false
                
                PersistenceController.shared.save(bContext)
                CalendarManager.shared.updateExistingEvent(.notes(thisPair.session!))
            }
        }
    }
    
    ///when user types in a new note instead of selecting an existing note
    private func saveNoteToCoreData(_ note:String, for pair: Pair) {
        let objID = pair.objectID
        
        DispatchQueue.global().async {
            //clean up textInput by removing white spaces
            var trimmedNote = note
            trimmedNote.removeWhiteSpaceAtBothEnds()
            
            //avoid duplicates
            if notes
                .compactMap({ $0.note })
                .contains(trimmedNote) {
                
                selectExitingNote(trimmedNote)
                return
            }
            
            let thePair = PersistenceController.shared.grabObj(objID) as! Pair
            thePair.isNoteHidden = false
            
            //save note to CoreData if no duplicates
            viewModel.save(trimmedNote, forObject: thePair)
            UserFeedback.singleHaptic(.heavy)
        }
    }
    
    private var noteIsValid: Bool {
        let condition = !textInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        return textInput.count > 0 && condition ? true : false
    }
    
    private var emptyView:some View {
        ContentUnavailableView {
            Label("Empty List", systemImage: "list")
        } description: {
            Text("Lap Notes are shown here")
        } actions: {
            Button {
                viewModel.addExampleLapNotes(pair)
            } label: {
                Label("Give Me Ideas", systemImage: "lightbulb")
            }
        }
    }
    
    // MARK: -
    private func dismiss() {
        viewModel.pairNotes(.hide)
        secretary.setAddNoteButton_bRank(to: nil)
    }
}

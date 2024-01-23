//
//  LapNotesOverlay1.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 22.01.2024.
//

import SwiftUI
import MyPackage

protocol Note {
    var note:String? { get set}
    var date:Date? { get set}
}

struct LapNotesOverlay: View {
    @AppStorage(Storagekey.hasUserDeletedLapNote) private var hasUserDeletedNote = false
    
    @Environment(ViewModel.self) private var viewModel
    @Environment(Secretary.self) private var secretary
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var bubble:Bubble?
    let pair:Pair
    @State private var notes:[PairSavedNote]
    @State private var textInput = ""
    
    let initialNote:String
    
    private var stickyNoteIsValid: Bool {
        //only empty space ex: "    "
        let onlyEmptySpace = textInput.isAllEmptySpace
        
        if !textInput.isEmpty && !onlyEmptySpace { return true }
        if initialNote == textInput { return false }
        
        return false
    }
    
    private let textInputLimit = 12
    
    @FocusState var isKeyboardVisible:Bool
    
    // MARK: -
    init?(_ tuple:(Pair?, [PairSavedNote])?) {
        guard let tuple = tuple else { return nil }
        guard let pair = tuple.0 else { return nil }
        
        self.pair = pair
        self.initialNote = pair.note_
        _notes = State(initialValue: tuple.1)
    }
    
    // MARK: -
    private var filteredStickyNotes:[PairSavedNote] {
        if textInput.isEmpty { return notes }
        let filtered = notes.filter { $0.note!.lowercased().contains(textInput.lowercased()) }
        return filtered
    }
    
    private func deleteTextFieldText() {
        UserFeedback.doubleHaptic(.rigid)
        textInput = ""
    }
    
    private func userTaps(_ note:PairSavedNote) {
        viewModel.userChoseFromList = true
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
                                ForEach (filteredStickyNotes) { note in
                                    if let string = note.note {
                                        Color.item
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
                                                if !hasUserDeletedNote {
                                                    hasUserDeletedNote = true
                                                }
                                            }
                                    }
                                }
                                .frame(height: 46)
                            }
                            .font(.system(size: 26))
                        } else {
                            if notes.isEmpty && textInput.isEmpty {
                                emptyView
                            } else {
                                ClearSaveHintView()
                                    .padding(.top)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.init(top: 0, leading: 8, bottom: 8, trailing: 8))
                    .frame(idealHeight: isPortrait ? 294 : 280, maxHeight: isPortrait ? 294 : 280) //⚠️
                    .overlay(alignment: .bottom) { deleteNoteHint }
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: isPortrait ? 360 : 700)
                .compositingGroup()
                .standardShadow()
                .onChange(of: textInput, initial: false) { viewModel.stickyNoteText = $1 }
            } action: {
                dismiss()
            }
        }
        .swipeToClear {
            if !textInput.isEmpty { textInput = "" }
        }
        .onDisappear { onDisappear() }
    }
    
    private func onDisappear() {
        if viewModel.userChoseFromList {
            secretary.showConfirmAddLapNote()
            viewModel.userChoseFromList = false
            viewModel.stickyNoteText = ""
            return
        }
        if !viewModel.stickyNoteText.isEmpty {
            secretary.showConfirmAddLapNote()
            saveNoteToCoreData(viewModel.stickyNoteText, for: pair)
            viewModel.stickyNoteText = ""
            viewModel.pairNotes(.hide)
        }
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
                
                PersistenceController.shared.save(bContext) {
                    if let bubble = thisPair.session?.bubble {
                        CalendarManager.shared.updateEvent(.title(bubble))
                    }
                }
            }
        }
    }
    
    ///when user types in a new note instead of selecting an existing note
    private func saveNoteToCoreData(_ note:String, for pair: Pair) {
        let objID = pair.objectID
        
        DispatchQueue.global().async {
            //clean up textInput by removing white spaces
            var noteCopy = note
            noteCopy.removeWhiteSpaceAtBothEnds()
            
            //avoid duplicates
            if notes
                .compactMap({ $0.note })
                .contains(noteCopy) {
                
                selectExitingNote(noteCopy)
                return
            }
            
            let bContext = PersistenceController.shared.bContext
            bContext.perform {
                let thePair = PersistenceController.shared.grabObj(objID) as! Pair
                thePair.isNoteHidden = false
                UserFeedback.singleHaptic(.heavy)
                viewModel.save(noteCopy, forObject: thePair)
                
                PersistenceController.shared.save(bContext) {
                    if let session = thePair.session {
                        CalendarManager.shared.updateEvent(.notes(session))
                    }
                    
                    if let bubble = thePair.session?.bubble {
                        CalendarManager.shared.updateEvent(.title(bubble))
                    }
                }
            }
        }
    }
    
    private var noteIsValid: Bool {
        let condition = !textInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        return textInput.count > 0 && condition ? true : false
    }
    
    private var emptyView:some View {
        ContentUnavailableView {
            Text("Empty List")
                .fontWeight(.medium)
        } description: {
            Text("Lap Notes are shown here")
        } actions: {
            Button {
                viewModel.addExampleLapNotes(pair)
                delayExecution(.now() + 0.15) {
                    withAnimation(.bouncy) {
                        reloadNotes()
                    }
                }
            } label: {
                Label("Need Ideas?", systemImage: "lightbulb")
            }
        }
    }
    
    @ViewBuilder
    private var deleteNoteHint:some View {
        if !hasUserDeletedNote && (1...7).contains(notes.count) && !filteredStickyNotes.isEmpty {
            Text("Touch and hold to delete")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
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
    
    private var textField: some View {
        TextField("Enter Lap Note", text: $textInput)
            .foregroundStyle(.label2)
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
    
    // MARK: -
    private func dismiss() {
        viewModel.pairNotes(.hide)
        secretary.setAddNoteButton_bRank(to: nil)
        SmallHelpOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
    }
    
    private func reloadNotes() {
        let request = PairSavedNote.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \PairSavedNote.date, ascending: false)]
        if let results = try? PersistenceController.shared.viewContext.fetch(request) {
            notes = results
        }
    }
}

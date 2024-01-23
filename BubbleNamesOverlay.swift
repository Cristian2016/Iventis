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
//2 store initial note

import SwiftUI
import MyPackage

struct BubbleNamesOverlay: View {
    let bubble:Bubble  /* ⚠️ do not use @StateObject bubble:Bubble! because each time Bubble.bubbleCell_Components update, bubble will emit and body will get recomputed each mother fucking second!!!
                        */
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Environment(ViewModel.self) private var viewModel
    @FetchRequest private var notes:FetchedResults<BubbleSavedNote>
    @State private var textInput = "" //willSet and didSet do not work anymore
    
    @FocusState private var isKeyboardVisible:Bool
    
    @AppStorage(Storagekey.hasUserDeletedBubbleNote) private var hasUserDeletedNote = false
    
    private let textInputLimit = 9
    
    let initialNote:String
    
    private let size = CGSize(width: 250, height: 412)
    private let cornerRadius = CGFloat(24)
    
    private var emptyView:some View {
        ContentUnavailableView {
            Text("Empty List")
                .fontWeight(.medium)
        } description: {
            Text("Bubble Notes are shown here")
        } actions: {
            Button {
                viewModel.addExampleBubbleNotes(bubble)
            } label: {
                Label("Need Ideas?", systemImage: "lightbulb")
            }
        }
    }
    
    // MARK: -
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        self.bubble = bubble
        self.initialNote = bubble.note_ //2
        
        let sorts = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        _notes = FetchRequest(entity: BubbleSavedNote.entity(),
                              sortDescriptors: sorts,
                              predicate: nil,
                              animation: .default)
    }
    
    // MARK: -
    private func dismiss() {
        SmallHelpOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
        
        withAnimation(.bouncy(duration: 0.15)) {
            viewModel.notes_Bubble = nil
        }
    }
    
    private var textField: some View {
        TextField("Enter Bubble Name", text: $textInput)
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
    
    private func saveNoteAndDismiss() {
        guard isNoteValid else {
            UserFeedback.singleHaptic(.light)
            dismiss()
            return
        }
        
        UserFeedback.singleHaptic(.heavy)
        dismiss()
    }
    
    private var isNoteValid: Bool {
        //only empty space ex: "    "
        let onlyEmptySpace = textInput.isAllEmptySpace
        
        if !textInput.isEmpty && !onlyEmptySpace { return true }
        if initialNote == textInput { return false }
        
        return false
    }
    
    private var filteredNotes:[BubbleSavedNote] {
        if textInput.isEmpty { return notes.map { $0 } }
        
        return notes
            .map { $0 }
            .filter { $0.note!.lowercased().contains(textInput.lowercased()) }
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
    
    private func userTaps(_ note:BubbleSavedNote) {
        viewModel.userChoseFromList = true
        viewModel.selectExisting(note, initialNote, bubble)
        dismiss()
    }
    
    func selectExisting(_ note:PairSavedNote, _ initialNote:String, _ pair:Pair) {
        if initialNote == note.note { return }
        
        UserFeedback.singleHaptic(.light)
        
        let bContext = PersistenceController.shared.bContext
        let objID = pair.objectID
        let objID1 = note.objectID
        
        bContext.perform {
            let bPair = PersistenceController.shared.grabObj(objID) as! Pair
            let thisPairNote = PersistenceController.shared.grabObj(objID1) as! PairSavedNote
            
            //set pair.note and show note
            bPair.note = note.note
            bPair.isNoteHidden = false
            
            thisPairNote.bubble = bPair.session?.bubble
            note.date = Date()
            
            PersistenceController.shared.save(bContext) {
                if let bubble = bPair.session?.bubble {
                    CalendarManager.shared.updateEvent(.title(bubble))
                }
            }
        }
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
                            if filteredNotes.isEmpty { Separator() }
                        }
                    ScrollView {
                        let columnsCount = verticalSizeClass == .compact ? 4 : 2
                        let columns = Array(repeating: GridItem(spacing: 1), count: columnsCount)
                        
                        if !filteredNotes.isEmpty {
                            LazyVGrid(columns: columns, spacing: 1) {
                                ForEach (filteredNotes) { note in
                                    Color.item
                                        .overlay{
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
                                                            viewModel.deleteBubbleNote(note)
                                                        }
                                                        if !hasUserDeletedNote {
                                                            hasUserDeletedNote = true
                                                        }
                                                    }
                                            }
                                        }
                                        .onLongPressGesture {
                                            viewModel.deleteBubbleNote(note)
                                        }
                                }
                                .frame(height: 46)
                            }
                            .font(.system(size: 26))
                        } else {
                            if notes.isEmpty {
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
        .onDisappear {
            if viewModel.userChoseFromList {
                viewModel.userChoseFromList = false
                viewModel.stickyNoteText = ""
                return
            }
            
            if !viewModel.stickyNoteText.isEmpty {
                saveNoteToCoreData(viewModel.stickyNoteText, for: bubble)
                viewModel.stickyNoteText = ""
                viewModel.notes_Bubble = nil
            }
        }
    }
    
    // MARK: -
    private func moveNoteAtTheBegginingOfTheList(for note:String) {
        //don't move note if it's on top already
        guard notes.first?.note != note else { return }
        
        //move selected note on top of the list
        if let bubbleSavedNote = notes.filter({ $0.note == note }).first {
            let objID = bubbleSavedNote.objectID
            
            PersistenceController.shared.bContext.perform {
                let bBubbleSavedNote = PersistenceController.shared.grabObj(objID) as? BubbleSavedNote
                bBubbleSavedNote?.date = Date()
                //no need to save bContext, because selectExistingNote will save anyway :)
            }
        }
    }
    
    private func selectExitingNote(_ note:String) {
        DispatchQueue.global().async {
            var noteCopy = note
            noteCopy.removeWhiteSpaceAtBothEnds()
            
            if initialNote == noteCopy { return }
            
            UserFeedback.singleHaptic(.heavy)
            
            self.moveNoteAtTheBegginingOfTheList(for: note)
            
            let bContext = PersistenceController.shared.bContext
            let objID = bubble.objectID
            
            bContext.perform {
                let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                bBubble.name = noteCopy
                bBubble.isNoteHidden = false
                
                PersistenceController.shared.save(bContext) {
                    CalendarManager.shared.updateEvent(.title(bBubble))
                }
            }
        }
    }
    
    private func saveNoteToCoreData(_ note:String, for bubble: Bubble) {
        //avoid duplicates
        //save note to CoreData if no duplicates
        let objID = bubble.objectID
        
        DispatchQueue.global().async {
            var noteCopy = note
            noteCopy.removeWhiteSpaceAtBothEnds()
            
            if notes.compactMap({ $0.note }).contains(noteCopy) {
                selectExitingNote(note)
                return
            }
            
            let bContext = PersistenceController.shared.bContext
            
            bContext.perform {
                let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                viewModel.save(noteCopy.capitalized, forObject: bBubble)
                UserFeedback.singleHaptic(.heavy)
                bBubble.isNoteHidden = false
                
                PersistenceController.shared.save(bContext) {
                    CalendarManager.shared.updateEvent(.title(bBubble))
                }
            }
        }
    }
    
    @ViewBuilder
    private var deleteNoteHint:some View {
        if !hasUserDeletedNote && !filteredNotes.isEmpty && (1...7).contains(notes.count) {
            Text("Touch and hold to delete")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
    }
}

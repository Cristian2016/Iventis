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
import MyPackage

struct PairNotesOverlay: View {
    let pair:Pair
    @Environment(ViewModel.self) private var viewModel
    
    @FetchRequest private var pairSavedNotes:FetchedResults<PairSavedNote>
    @State private var textInput = "" //willSet and didSet do not work anymore
    @Environment(Secretary.self) private var secretary
    
    private let textInputLimit = 12
    private let line0 = "No Matches"
    
    let initialNote:String
    @FocusState var keyboardVisible:Bool
    
    private let size = CGSize(width: 220, height: 382)
    private let cornerRadius = CGFloat(24)
    
    // MARK: -
    init?(_ pair:Pair?) {
        guard let pair = pair else { return nil }
        
        self.pair = pair
        self.initialNote = pair.note_
        
        let sorts = [
//            NSSortDescriptor(key: "bubble", ascending: false), //⚠️ crashes for some reason..
            NSSortDescriptor(key: "date", ascending: false)
        ]
        _pairSavedNotes = FetchRequest(entity: PairSavedNote.entity(), sortDescriptors: sorts, predicate: nil, animation: .default)
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
    
    // MARK: -
    var body: some View {
        NotesOverlay(
            stickyNotes: pairSavedNotes.compactMap { $0.note },
            textInputLimit: textInputLimit,
            initialNote: initialNote,
            //actions
            bubble: pair.session?.bubble,
            deleteStickyNote: { text in
                let note = pairSavedNotes.filter { $0.note == text }.first
                viewModel.deletePairNote(note)
            },
            selectExistingNote: { selectExitingNote($0)}, 
            kind: .pair
        )
        .onDisappear {
            if viewModel.userChoseNoteInTheList {
                viewModel.userChoseNoteInTheList = false
                viewModel.stickyNoteText = ""
                return
            }
            if !viewModel.stickyNoteText.isEmpty {
                saveNoteToCoreData(viewModel.stickyNoteText, for: pair)
                viewModel.stickyNoteText = ""
                viewModel.notes_Pair = nil
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
            if pairSavedNotes
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
    
    // MARK: -
    private func dismiss() {
        viewModel.notes_Bubble = nil
        secretary.addNoteButton_bRank = nil
    }
}

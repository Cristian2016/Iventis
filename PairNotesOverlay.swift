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
    
    @FetchRequest private var allPairSavedNotes:FetchedResults<PairSavedNote>
    @FetchRequest private var thisPairNotes:FetchedResults<PairSavedNote>
    
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
        guard let pair = pair, let bubble = pair.session?.bubble else { return nil }
        
        self.pair = pair
        self.initialNote = pair.note_
        
        let predicate = NSPredicate(format: "bubble = %@", bubble)
        let sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        _thisPairNotes = FetchRequest(sortDescriptors: sortDescriptors, predicate: predicate)
        
        let sorts = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        let predicate1 = NSPredicate(format: "bubble != %@", bubble)
        _allPairSavedNotes = FetchRequest(entity: PairSavedNote.entity(), sortDescriptors: sorts, predicate: predicate1, animation: .default)
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
        let allNotes = thisPairNotes.compactMap(\.note) + allPairSavedNotes.compactMap(\.note)
        
        NotesOverlay(
            stickyNotes: allNotes,
            textInputLimit: textInputLimit,
            initialNote: initialNote,
            //actions
            bubble: pair.session?.bubble,
            deleteStickyNote: { text in
                if let note = allPairSavedNotes.filter({ $0.note == text }).first {
                    viewModel.deletePairNote(note)
                } else {
                    let result = thisPairNotes.filter { $0.note == text }.first
                    viewModel.deletePairNote(result)
                }
            },
            selectExistingNote: { note in
                selectExitingNote(note)
            },
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
    
    private func moveNoteAtTheBegginingOfTheList(for note:String) {
        //don't move note if it's on top already
        guard 
            allPairSavedNotes.first?.note != note ||
                thisPairNotes.first?.note != note
        else { return }
        
        //move selected note on top of the list
        if let pairSavedNote = allPairSavedNotes.filter({ $0.note == note }).first {
            let objID = pairSavedNote.objectID
            
            PersistenceController.shared.bContext.perform {
                let bPairSavedNote = PersistenceController.shared.grabObj(objID) as? PairSavedNote
                bPairSavedNote?.date = Date()
                //no need to save bContext, because selectExistingNote will save anyway :)
            }
            return
        }
        
        if let pairSavedNote = thisPairNotes.filter({ $0.note == note }).first {
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
    
    private func selectExistingNote(_ pairSavedNote:PairSavedNote) {
        
    }
    
    ///when user types in a new note instead of selecting an existing note
    private func saveNoteToCoreData(_ note:String, for pair: Pair) {
        let objID = pair.objectID
        
        DispatchQueue.global().async {
            //clean up textInput by removing white spaces
            var trimmedNote = note
            trimmedNote.removeWhiteSpaceAtBothEnds()
            
            //avoid duplicates
            if allPairSavedNotes
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

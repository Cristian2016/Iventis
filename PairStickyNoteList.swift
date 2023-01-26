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

struct PairStickyNoteList: View {
    let pair:Pair
    @EnvironmentObject private var vm:ViewModel
    @FetchRequest private var pairSavedNotes:FetchedResults<PairSavedNote>
    @State private var textInput = "" //willSet and didSet do not work anymore
    
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
        StickyNoteList(stickyNotes: pairSavedNotes.compactMap { $0.note },
                  textInputLimit: textInputLimit,
                  initialNote: initialNote,
                  //actions
                  dismiss: { dismiss() },
                  deleteStickyNote: { vm.delete(pairSavedNotes[$0!]) },
                  saveNoteToCoredata: {
            if !$0.isEmpty {  saveNoteToCoreData($0, for: pair) }
        }, selectExistingNote: { selectExitingNote($0) }
        )
    }
    
    ///when user types in a new note instead of selecting an existing note
    private func saveNoteToCoreData(_ note:String, for pair: Pair) {
        //clean up textInput by removing white spaces
        var trimmedNote = note
        trimmedNote.removeWhiteSpaceAtBothEnds()
        
        //avoid duplicates
        if pairSavedNotes.compactMap({ $0.note }).contains(trimmedNote) {
            selectExitingNote(trimmedNote)
            return
        }
        
        pair.isNoteHidden = false
        
        //save note to CoreData if no duplicates
        vm.save(trimmedNote, forObject: pair)
        UserFeedback.singleHaptic(.heavy)
    }
    
    ///when user selects an existing note instead of typing in a new note
    private func selectExitingNote(_ note:String) {
        var trimmedNote = note
        trimmedNote.removeWhiteSpaceAtBothEnds()
        
        if initialNote == trimmedNote { return }
        
        UserFeedback.singleHaptic(.heavy)
        
        //set pair.note and show note
        pair.note = note
        pair.isNoteHidden = false
        
        try? PersistenceController.shared.viewContext.save()
        CalendarManager.shared.updateExistingEvent(.notes(pair.session!))
    }
    
    private var noteIsValid: Bool {
        let condition = !textInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        
        if textInput.count > 0 && condition {
            return true
        }
        
        return false
    }
    
    // MARK: -
    private func dismiss() { vm.pairOfNotesList = nil }
}

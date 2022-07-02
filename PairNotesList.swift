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

struct PairNotesList: View {
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
        NotesList(notes: pairSavedNotes.compactMap { $0.note },
                  textInputLimit: textInputLimit,
                  initialNote: initialNote,
                  //actions
                  dismiss: { dismiss() },
                  deleteItem: { vm.delete(pairSavedNotes[$0!]) },
                  saveNoteToCoredata: { saveNoteToCoreData($0, for: pair) },
                  selectExistingNote: { chooseExitingNote($0) }
        )
    }
    
    private func chooseExitingNote(_ note:String) {
        UserFeedback.singleHaptic(.heavy)
        pair.note = note
        try? PersistenceController.shared.viewContext.save()
    }
    
    private func saveNoteToCoreData(_ note:String, for pair: Pair) {
        //avoid duplicates
        //save note to CoreData if no duplicates
        
        var trimmedNote = note
        trimmedNote.removeWhiteSpaceAtBothEnds()
        if pairSavedNotes.compactMap({ $0.note }).contains(trimmedNote) { return }
        vm.save(trimmedNote, forObject: pair)
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

//struct PairStickyNotesList_Previews: PreviewProvider {
//    static var previews: some View {
//        PairStickyNotesList(<#Pair#>)
//    }
//}

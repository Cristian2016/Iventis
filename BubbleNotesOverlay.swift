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

struct BubbleNotesOverlay: View {
    let bubble:Bubble  /* ⚠️ do not use @StateObject bubble:Bubble! because each time Bubble.bubbleCell_Components update, bubble will emit and body will get recomputed each mother fucking second!!!
                        */
    
    @Environment(ViewModel.self) private var viewModel
    @FetchRequest private var bubbleSavedNotes:FetchedResults<BubbleSavedNote>
    @State private var textInput = "" //willSet and didSet do not work anymore
    
    //if <2 show userInfo, else hide forever
    @AppStorage("rowDeleteCount") var rowDeleteCount = 0
        
    private let textInputLimit = 9
    
    let initialNote:String
    
    private let size = CGSize(width: 250, height: 412)
    private let cornerRadius = CGFloat(24)
    
    // MARK: -
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        self.bubble = bubble
        self.initialNote = bubble.note_ //2
                
        let sorts = [
//            NSSortDescriptor(key: "bubble.rank", ascending: false),
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        _bubbleSavedNotes = FetchRequest(entity: BubbleSavedNote.entity(),
                                         sortDescriptors: sorts,
                                         predicate: nil,
                                         animation: .default)
    }
    
    // MARK: -
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .global)
            .onChanged { if $0.translation.width < -20 { textInput = "" } }
            .onEnded { _ in if textInput.isEmpty { UserFeedback.doubleHaptic(.rigid) }}
    }
        
    // MARK: -
    var body: some View {
        NotesOverlay(
            stickyNotes: bubbleSavedNotes.compactMap { $0.note },
            textInputLimit: textInputLimit,
            initialNote: initialNote,
            //actions
            bubble: bubble, 
            deleteStickyNote: { text in
                let note = bubbleSavedNotes.filter { $0.note == text }.first
                viewModel.deleteBubbleNote(note)
            },
            selectExistingNote: { selectExitingNote($0) },
            kind: .bubble
        )
        .onDisappear {
            if viewModel.userChoseNoteInTheList {
                viewModel.userChoseNoteInTheList = false
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
        guard bubbleSavedNotes.first?.note != note else { return }
        
        //move selected note on top of the list
        if let bubbleSavedNote = bubbleSavedNotes.filter({ $0.note == note }).first {
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
                let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                thisBubble.note = noteCopy
                thisBubble.isNoteHidden = false
                PersistenceController.shared.save(bContext)
                
                DispatchQueue.main.async {
                    CalendarManager.shared.updateExistingEvent(.title(bubble))
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
            if bubbleSavedNotes.compactMap({ $0.note }).contains(noteCopy) {
                selectExitingNote(note)
                return
            }
                        
            let bContext = PersistenceController.shared.bContext
            
            bContext.perform {
                let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                viewModel.save(noteCopy.capitalized, forObject: thisBubble)
                UserFeedback.singleHaptic(.heavy)
                thisBubble.isNoteHidden = false
                PersistenceController.shared.save(bContext)
            }
        }
    }
}

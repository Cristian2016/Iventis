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

struct BubbleNotesList: View {
    let bubble:Bubble  /* ⚠️ do not use @StateObject bubble:Bubble! because each time Bubble.bubbleCell_Components update, bubble will emit and body will get recomputed each mother fucking second!!!  */
    @EnvironmentObject private var vm:ViewModel
    @FetchRequest private var bubbleSavedNotes:FetchedResults<BubbleSavedNote>
    @State private var textInput = "" //willSet and didSet do not work anymore
    
    //if <2 show userInfo, else hide forever
    @AppStorage("rowDeleteCount") var rowDeleteCount = 0
        
    private let textInputLimit = 9
    private let textFieldPlaceholder = "Add/Search Note"
    private let line0 = "No Matches"
    private let line1 = Text("Tap \(Image(systemName: "plus.app.fill")) to Save Note")
        .font(.system(size: 23))
    private let line2 = Text("Tap Hold \(Image(systemName: "plus.app.fill")) to Delete").font(.system(size: 21))
    private let line3 = Text("Empty Notes will not be saved").font(.system(size: 21))
    
    let initialNote:String
    @Binding var showAddNotes_bRank:Int?
    
    private let size = CGSize(width: 250, height: 412)
    private let cornerRadius = CGFloat(24)
    
    // MARK: -
    init(_ notesList_bRank:Binding<Int?>) {
        //set Bubble
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", notesList_bRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        self.bubble = bubble
        
        //set initial note
        self.initialNote = bubble.note_
        
        let sorts = [
//            NSSortDescriptor(key: "bubble", ascending: false), //⚠️ crashes for some reason..
            NSSortDescriptor(key: "date", ascending: false)
        ]
        _bubbleSavedNotes = FetchRequest(entity: BubbleSavedNote.entity(), sortDescriptors: sorts, predicate: nil, animation: .default)
        _showAddNotes_bRank = Binding(projectedValue: notesList_bRank)
    }
    
    // MARK: -
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .global)
            .onChanged { if $0.translation.width < -20 { textInput = "" } }
            .onEnded { _ in if textInput.isEmpty { UserFeedback.doubleHaptic(.rigid) }
            }
    }
        
    // MARK: -
    var body: some View {
        NotesList(notes: bubbleSavedNotes.compactMap { $0.note },
                  textInputLimit: textInputLimit,
                  initialNote: initialNote,
                  //actions
                  dismiss: { dismiss() },
                  deleteItem: { vm.delete(bubbleSavedNotes[$0!]) },
                  saveNoteToCoredata: { saveNoteToCoreData($0, for: bubble) },
                  selectExistingNote: { selectExitingNote($0) }
        )
    }
        
    // MARK: -
    private func dismiss() { showAddNotes_bRank = nil }
    
    private func selectExitingNote(_ note:String) {
        print(#function)
        var trimmedNote = note
        trimmedNote.removeWhiteSpaceAtBothEnds()
        
        if initialNote == trimmedNote { return }
        
        UserFeedback.singleHaptic(.heavy)
        bubble.note = note
        try? PersistenceController.shared.viewContext.save()
        
        CalendarManager.shared.updateExistingEvent(.title(bubble))
    }
    
    private func saveNoteToCoreData(_ note:String, for bubble: Bubble) {
        //avoid duplicates
        //save note to CoreData if no duplicates
        
        var trimmedNote = note
        trimmedNote.removeWhiteSpaceAtBothEnds()
        if bubbleSavedNotes.compactMap({ $0.note }).contains(trimmedNote) {
            selectExitingNote(trimmedNote)
            return
        }
        
        vm.save(note, forObject: bubble)
        UserFeedback.singleHaptic(.heavy)
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNotesList(.constant(0))
    }
}

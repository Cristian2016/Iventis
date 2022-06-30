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

struct BubbleStickyNotesList: View {
    let bubble:Bubble  /* ⚠️ do not use @StateObject bubble:Bubble! because each time Bubble.bubbleCell_Components update, bubble will emit and body will get recomputed each mother fucking second!!!  */
    @EnvironmentObject private var viewModel:ViewModel
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
    init(_ stickyNotesList_bRank:Binding<Int?>) {
        //set Bubble
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank == %i", stickyNotesList_bRank.wrappedValue!)
        
        guard let bubble = try? PersistenceController.shared.viewContext.fetch(request).first else { fatalError("fuck bubble") }
        self.bubble = bubble
        
        //set initial note
        self.initialNote = bubble.note_
        
        let sorts = [
//            NSSortDescriptor(key: "bubble", ascending: false), //⚠️ crashes for some reason..
            NSSortDescriptor(key: "date", ascending: false)
        ]
        _bubbleSavedNotes = FetchRequest(entity: BubbleSavedNote.entity(), sortDescriptors: sorts, predicate: nil, animation: .default)
        _showAddNotes_bRank = Binding(projectedValue: stickyNotesList_bRank)
    }
    
    // MARK: -
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .global)
            .onChanged {
                if $0.translation.width < -20 { textInput = "" }
            }
            .onEnded { _ in
                if textInput.isEmpty { UserFeedback.doubleHaptic(.rigid)
                }
            }
    }
    private func saveTextAndDismiss() {
        saveTextInput()
        dismiss()
    }
        
    // MARK: -
    var body: some View {
        NotesList(notes: bubbleSavedNotes.compactMap { $0.note },
                  textInputLimit: textInputLimit,
                  initialNote: initialNote,
                  //actions
                  dismiss: { dismiss() },
                  deleteItem: { viewModel.delete(bubbleSavedNotes[$0!]) },
                  saveNoteToCoredata: { viewModel.save($0, for: bubble) },
                  selectExistingNote: { chooseExitingNote($0) }
        )
        .offset(y: 10)
        .ignoresSafeArea(.container, edges: .top)
    }
    
    private var remainingCharactersCounterView:some View {
        Text("\(textInputLimit - textInput.count)")
            .font(.system(size: 18).weight(.medium))
            .foregroundColor(.white)
            .offset(x: 15, y: 15)
    }
    
    // MARK: -
    private func dismiss() { showAddNotes_bRank = nil }
    
    private func saveTextInput() {
        if initialNote == textInput || textInput.isEmpty { return }
        
        viewModel.save(textInput, for: bubble)
        UserFeedback.singleHaptic(.heavy)
        
        PersistenceController.shared.save()
    }
    
    private func chooseExitingNote(_ note:String) {
        UserFeedback.singleHaptic(.heavy)
        bubble.note = note
        try? PersistenceController.shared.viewContext.save()
    }
}

struct BubbleNoteView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleStickyNotesList(.constant(0))
    }
}

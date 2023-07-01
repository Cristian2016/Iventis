//
//  AddTagButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.

import SwiftUI
import MyPackage

///button that triggers an action to add a PairCell note
struct AddNoteButton: View {
    private let secretary = Secretary.shared
    @EnvironmentObject private var viewModel:ViewModel
    @State private var addNoteButton_bRank:Int?
    @State private var newColor:Color?
    
    var body: some View {
        ZStack {
            if let rank = addNoteButton_bRank,
               let bubble = viewModel.bubble(for: Int(rank)) {
                let color = newColor ?? Color.bubbleColor(forName: bubble.color)
                
                FusedLabel(content: .addNote(color))
                    .onTapGesture { tapped(bubble) }
            }
        }
        .onReceive(secretary.$addNoteButton_bRank) { addNoteButton_bRank = $0 }
    }
    
    private func tapped(_ bubble:Bubble) {
        UserFeedback.singleHaptic(.light)
        viewModel.notesForPair.send(bubble.lastPair)
    }
}

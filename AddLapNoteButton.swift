//
//  AddTagButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.

import SwiftUI
import MyPackage

///button that triggers an action to add a PairCell note
struct AddLapNoteButton: View {
    @Environment(Secretary.self) private var secretary
    @Environment(ViewModel.self) private var viewmodel
    
    @State private var newColor:Color?
    
    var body: some View {
        @Bindable var nvm = viewmodel
        ZStack {
            if let rank = secretary.addNoteButton_bRank,
               let bubble = viewmodel.bubble(for: Int(rank)) {
                
                let color = newColor ?? Color.bubbleColor(forName: bubble.color)
                FusedLabel(content: .addNote(color))
                    .onTapGesture { handleTap(bubble) }
            }
        }
    }
    
    private func handleTap(_ bubble:Bubble) {
        HintOverlay.Model.shared.topmostView(.lapNotes)
        UserFeedback.singleHaptic(.light)
        viewmodel.notes_Pair = bubble.lastPair
        delayExecution(.now() + 0.1) {
            secretary.addNoteButton_bRank = nil
        }
    }
}

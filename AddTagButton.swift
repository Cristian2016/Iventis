//
//  AddTagButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI
import MyPackage

struct AddTagButton: View {
    @EnvironmentObject private var viewModel:ViewModel
    
    let bubble:Bubble
    let color:Color
    
    init(_ bubble: Bubble) {
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
    }
    
    var body: some View {
        Button {
            let bubble = viewModel.bubble(for: Int(viewModel.fiveSeconds_bRank!))!
            viewModel.pairOfNotesList = bubble.lastPair
            UserFeedback.singleHaptic(.light)
            PersistenceController.shared.save()
        } label: {
            FusedLabel(content: .init(title: "Add Note", symbol: "note.text", size: .small, color: color, isFilled: true))
        }
    }
}

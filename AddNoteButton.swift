//
//  AddTagButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI
import MyPackage

///button that triggers an action to add a PairCell note
struct AddNoteButton: View {
    private let secretary = Secretary.shared
    @EnvironmentObject private var viewModel:ViewModel
    @State private var addNoteButton_bRank:Int?
    
    var body: some View {
        content
            .onReceive(secretary.$addNoteButton_bRank) {
                addNoteButton_bRank = $0
            }
    }
    
    // MARK: - Lego
    @ViewBuilder
    private var content:some View {
        if let rank = addNoteButton_bRank {
            let bubble = viewModel.bubble(for: Int(rank))!
            let color = Color.bubbleColor(forName: bubble.color)
            Button {
                viewModel.pairOfNotesList = bubble.lastPair
                UserFeedback.singleHaptic(.light)
                PersistenceController.shared.save()
            } label: {
                FusedLabel(content: .init(title: "Add Note", symbol: "text.alignleft", size: .small, color: color, isFilled: true))
            }
        } else {
            EmptyView()
        }
    }
}

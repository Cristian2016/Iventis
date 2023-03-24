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
                
                Button {
                    UserFeedback.singleHaptic(.light)
                    viewModel.notesForPair.send(bubble.lastPair)
                } label: {
                    FusedLabel(content: .init(title: "Add Note",
                                              symbol: "text.alignleft",
                                              size: .small,
                                              color: color,
                                              isFilled: true)
                    )
                }
//                .transition(.asymmetric(insertion: .scale, removal: .identity))
            }
        }
        .onReceive(secretary.$addNoteButton_bRank) { output in
            
            withAnimation {
                addNoteButton_bRank = output
            }
        }
    }
}

//
//  UnitedViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.01.2023.
//
//10 is this overkill? A single obsevable object only to manage the navigationStack?? Not sure though

import SwiftUI

typealias Device = UIDevice

struct ViewHierarchy: View {
    @Environment(Secretary.self) private var secretary
    @Environment(ViewModel.self) private var viewModel
        
    var body: some View {
        ZStack {
            @Bindable var nvm = viewModel
            
            NavigationStack(path: $nvm.path) {
                BubbleList()
                    .navigationTitle("") //1
                    .navigationBarTitleDisplayMode(.inline) //1
            }
            .tint(.label2)
            .overlay { CalAccessDeniedAlert() }
            .overlay { BubbleNamesOverlay(viewModel.notes_Bubble) }
            .overlay { LapNotesOverlay(viewModel.pairNotes) }
            .overlay { MoreOptionsOverlay(viewModel.moreOptionsSheetBubble) }
            .overlay { PaletteView() }
            .overlay {
                if let rank = secretary.controlActionBubble {
                    ControlOverlay(viewModel.bubble(for: Int(rank)))
                }
            }
            .overlay { DurationPickerOverlay(reason: viewModel.durationPicker.reason) }
            .overlay { SmallHelpOverlay() }
            .overlay(alignment: .topLeading) { SmallHelpOverlay.ShakeHelpButton() }
            
            CaffeinatedAlert()
            CaffeinatedConfirmation()
            
            CalendarEventCreatedConfirmation()
            CalendarEventRemovedConfirmation()
            
            AddNoteConfirmation()
            
            BigHelpOverlay(secretary.showBigHelpOverlay)
        }
    }
}

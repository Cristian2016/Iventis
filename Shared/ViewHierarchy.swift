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
            if Device.isIPad { iPadViewHierarchy() }
            else { iPhoneViewHierarchy() }
            
            if let rank = secretary.controlActionBubble {
                ControlOverlay(viewModel.bubble(for: Int(rank)))
            }
            
            AlwaysOnDisplayAlertView() //shown until user removes it forever
            ScreenAlwaysOnConfirmation() //shown each time user toggles the button in toolbar
            CalendarEventCreatedConfirmation()
            CalendarEventRemovedConfirmation()
        }
        .overlay { WarningLabel() }
        .overlay { BubbleNotesOverlay(viewModel.notes_Bubble) }
        .overlay { PairNotesOverlay(viewModel.notes_Pair) }
        .overlay { MoreOptionsOverlay(viewModel.moreOptionsSheetBubble) }
        .overlay { PaletteView() }
        .overlay { DurationPickerOverlay(reason: viewModel.durationPicker.reason) }
        .overlay(alignment: .topLeading) { HelpOverlay.HelpButton() }
        .overlay { HelpOverlay() }
        .overlay { HelpViewHierarchy() }
    }
}

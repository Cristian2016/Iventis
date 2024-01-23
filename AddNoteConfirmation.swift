//
//  AddLapNoteConfirmationView.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 08.02.2024.
//

import SwiftUI

struct AddNoteConfirmation: View {
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if secretary.confirmAddLapNote {
                ConfirmOverlay(content: .lapNoteAdded)
            }
        }
    }
}

#Preview {
    AddNoteConfirmation()
}

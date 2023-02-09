//
//  AlwaysOnDisplayConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayConfirmationView: View {
    private let secretary = Secretary.shared
    @State var confirm_AlwaysOnDisplay = false
    
    var body: some View {
        ZStack {
            if confirm_AlwaysOnDisplay {
                ConfirmView(content: UIApplication.shared.isIdleTimerDisabled ? .alwaysONDisplayON : .alwaysONDisplayOFF)
            }
        }
        .onReceive(secretary.$confirm_AlwaysOnDisplay) {
            confirm_AlwaysOnDisplay = $0
        }
    }
}

struct AlwaysOnDisplayConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayConfirmationView()
    }
}

//
//  AlwaysOnDisplayConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    var isON:Bool { UIApplication.shared.isIdleTimerDisabled }
    
    var body: some View {
        ConfirmView(content: isON ? .alwaysONDisplayON : .alwaysONDisplayOFF)
    }
}

struct AlwaysOnDisplayConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayConfirmationView()
    }
}

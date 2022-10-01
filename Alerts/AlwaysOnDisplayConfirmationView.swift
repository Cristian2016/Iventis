//
//  AlwaysOnDisplayConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    var lowerSymbol:ConfirmationView.LowerSymbol {
        UIApplication.shared.isIdleTimerDisabled ? .on : .off
    }
    
    var body: some View {
        ConfirmationView(title: Alert.alwaysOnDisplay.title,
                         lowerSymbol: lowerSymbol) {  /* insert dismissAction here */ }
    }
}

struct AlwaysOnDisplayConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayConfirmationView()
    }
}

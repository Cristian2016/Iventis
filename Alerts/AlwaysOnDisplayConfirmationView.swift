//
//  AlwaysOnDisplayConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    var body: some View {
        ConfirmationView(titleSymbol: Alert.alwaysOnDisplay.titleSymbol, title: Alert.alwaysOnDisplay.title, isOn: UIApplication.shared.isIdleTimerDisabled)
    }
}

struct AlwaysOnDisplayConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayConfirmationView()
    }
}

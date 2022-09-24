//
//  AlwaysOnDisplayAlertView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayAlertView: View {
    @EnvironmentObject var viewModel:ViewModel
    @AppStorage("alwaysOnDisplay") var alwaysOnDisplay = true
    
    var body: some View {
        if alwaysOnDisplay {
            AlertView(alertContent: Alert.alwaysOnDisplay) {
                viewModel.showAlert_AlwaysOnDisplay = false
            } buttonAction: {
                alwaysOnDisplay = false
            }
        } else {
            AlwaysOnDisplayConfirmationView()
        }
    }
}

struct AlwaysOnDisplayAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayAlertView()
    }
}

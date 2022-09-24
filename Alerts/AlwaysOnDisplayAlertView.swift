//
//  AlwaysOnDisplayAlertView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayAlertView: View {
    @EnvironmentObject var viewModel:ViewModel
    @AppStorage("showAlwaysOnDisplayAlert") var showAlwaysOnDisplayAlert = true
    
    var body: some View {
        if showAlwaysOnDisplayAlert {
            AlertView(alertContent: Alert.alwaysOnDisplay) {
                viewModel.showAlert_AlwaysOnDisplay = false
            } buttonAction: { showAlwaysOnDisplayAlert = false }
        }
    }
}

struct AlwaysOnDisplayAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayAlertView()
    }
}

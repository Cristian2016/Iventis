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
    
    let secretary = Secretary.shared
    @State private var showAlert_AlwaysOnDisplay = false
    
    var body: some View {
        ZStack {
            if showAlwaysOnDisplayAlert, showAlert_AlwaysOnDisplay {
                AlertHintView(alertContent: AlertHint.deviceAutoLock) {
                    secretary.showAlert_AlwaysOnDisplay = false
                } buttonAction: { showAlwaysOnDisplayAlert = false }
            }
        }
        .onReceive(secretary.$showAlert_AlwaysOnDisplay) {
            showAlert_AlwaysOnDisplay = $0
        }
    }
}

struct AlwaysOnDisplayAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayAlertView()
    }
}

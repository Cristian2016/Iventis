//
//  AlwaysOnDisplayAlertView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayAlertView: View {
    @AppStorage("showAlwaysOnDisplayAlert") var showAlwaysOnDisplayAlert = true
    
    @Environment(Secretary.self) private var secretary
    @State private var showAlert_AlwaysOnDisplay = false
    
    var body: some View {
        ZStack {
            if showAlwaysOnDisplayAlert, showAlert_AlwaysOnDisplay {
                AlertHintView(alertContent: AlertHint.deviceAutoLock) {
                    secretary.showAlert_AlwaysOnDisplay = false
                } buttonAction: { showAlwaysOnDisplayAlert = false }
            }
        }
        .onChange(of: secretary.showAlert_AlwaysOnDisplay) {
            showAlert_AlwaysOnDisplay = $1
        }
    }
}

struct AlwaysOnDisplayAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayAlertView()
    }
}

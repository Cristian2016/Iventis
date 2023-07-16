//
//  AlwaysOnDisplayConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct ScreenAlwaysOnConfirmation: View {
    @Environment(Secretary.self) private var secretary
    @State var confirm_AlwaysOnDisplay = false
    
    var body: some View {
        ZStack {
            if confirm_AlwaysOnDisplay {
                ConfirmView(content: UIApplication.shared.isIdleTimerDisabled ? .appCaffeinated : .appCanSleep)
            }
        }
        .onChange(of: secretary.displayAutoLockConfirmation) {
            confirm_AlwaysOnDisplay = $1
        }
    }
}

struct AlwaysOnDisplayConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenAlwaysOnConfirmation()
    }
}

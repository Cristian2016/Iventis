//
//  AlwaysOnDisplayAlertView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct AlwaysOnDisplayAlertView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    var body: some View {
        AlertView(alertContent: Alert.alwaysOnDisplay) {
            viewModel.showAlert_AlwaysOnDisplay = false
        } buttonAction: {
            
        }
    }
}

struct AlwaysOnDisplayAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayAlertView()
    }
}

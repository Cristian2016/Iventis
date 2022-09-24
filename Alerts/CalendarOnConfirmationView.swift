//
//  CalendarOnConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct CalendarOnConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    var body: some View {
        ConfirmationView(titleSymbol: Alert.calendarOn.titleSymbol,
                         title: Alert.calendarOn.title,
                         isOn: viewModel.flashConfirmation_CalendarOn.isCalOn
        )
    }
}

struct CalendarOnConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarOnConfirmationView()
    }
}

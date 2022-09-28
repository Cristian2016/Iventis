//
//  CalendarOnConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct CalendarOnConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    //viewModel.confirm_CalendarOn.isCalOn
    var lowerSymbol:ConfirmationView.LowerSymbol {
        viewModel.confirm_CalendarOn.isCalOn ? .on : .off
    }
    
    var body: some View {
        ConfirmationView(titleSymbol: Alert.calendarOn.titleSymbol,
                         title: Alert.calendarOn.title, lowerSymbol: lowerSymbol
        )
    }
}

struct CalendarOnConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarOnConfirmationView()
    }
}

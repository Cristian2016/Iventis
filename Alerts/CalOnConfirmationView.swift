//
//  CalendarOnConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct CalOnConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    //viewModel.confirm_CalendarOn.isCalOn
    var lowerSymbol:ConfirmationView.LowerSymbol {
        viewModel.confirm_CalOn.isCalOn ? .on : .off
    }
    
    var body: some View {
        ConfirmationView(titleSymbol: AlertHint.calendarOn.titleSymbol,
                         title: AlertHint.calendarOn.title,
                         lowerSymbol: lowerSymbol,
                         dismissAction: { }
        )
    }
}

struct CalOnConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalOnConfirmationView()
    }
}

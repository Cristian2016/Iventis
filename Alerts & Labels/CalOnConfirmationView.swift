//
//  CalendarOnConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct CalOnConfirmationView: View {
    @EnvironmentObject var viewModel:ViewModel
    private let secretary = Secretary.shared
    @State var confirm_CalOn = (show:false, isCalOn:false)
    
    
    //viewModel.confirm_CalendarOn.isCalOn
    var lowerSymbol:ConfirmationView.LowerSymbol {
        viewModel.confirm_CalOn.isCalOn ? .on : .off
    }
    
    var body: some View {
        ZStack {
            if confirm_CalOn.show {
                ConfirmationView(titleSymbol: AlertHint.calendarOn.titleSymbol,
                                 title: AlertHint.calendarOn.title,
                                 lowerSymbol: lowerSymbol,
                                 dismissAction: { }
                )
            }
        }
        .onReceive(secretary.$confirm_CalOn) { confirm_CalOn = $0 }
    }
}

struct CalOnConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalOnConfirmationView()
    }
}

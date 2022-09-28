//
//  CalendarEventCreatedConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.09.2022.
//

import SwiftUI

struct CalendarEventCreatedConfirmationView: View {
    var body: some View {
        ConfirmationView(title: "Calendar Event", lowerSymbol: .done)
    }
}

struct CalendarEventCreatedConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarEventCreatedConfirmationView()
    }
}

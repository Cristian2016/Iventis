//
//  CalendarEventCreatedConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.09.2022.
//

import SwiftUI

struct CalendarEventCreatedConfirmationView: View {
    var body: some View {
        HStack {
            ConfirmationView(title: "Calendar Event",
                             lowerSymbol: .custom("OK"),
                             isBackgroundRemoved: true
            )
            Spacer()
        }
    }
}

struct CalendarEventCreatedConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarEventCreatedConfirmationView()
    }
}

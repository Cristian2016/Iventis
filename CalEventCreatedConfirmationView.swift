//
//  CalendarEventCreatedConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.09.2022.
//

import SwiftUI

struct CalEventCreatedConfirmationView: View {
    var body: some View {
        HStack {
            ConfirmationView(titleSymbol: "calendar",
                             title: "Event",
                             lowerSymbol: .custom("Saved"),
                             isBackgroundRemoved: true
            )
            Spacer()
        }
    }
}

struct CalendarEventCreatedConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalEventCreatedConfirmationView()
    }
}

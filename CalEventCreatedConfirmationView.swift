//
//  CalendarEventCreatedConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.09.2022.
//

import SwiftUI

struct CalEventCreatedConfirmationView: View {
    var body: some View {
        ConfirmationView1(content: .eventCreated) { /* dismiss action */}
    }
}

struct CalendarEventCreatedConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CalEventCreatedConfirmationView()
    }
}

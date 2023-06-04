//
//  CalendarView.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
//

import SwiftUI
import MyPackage

struct CalendarSticker: View {
    var body: some View {
        let calAccessGranted = CalendarManager.shared.calendarAccessStatus == .granted
        let imageName = calAccessGranted  ? "calendar" : "calendar.badge.exclamationmark"
        
        Image(systemName: imageName)
            .foregroundColor(.calendar)
            .font(.system(size: 43))
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSticker()
    }
}

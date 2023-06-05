//
//  CalendarView.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
// CalendarSticker must redraw if user grants access to Calendar
//

import SwiftUI
import MyPackage

struct CalendarSticker: View {
    @State private var redraw = false
    
    var body: some View {
        let calAccessGranted = CalendarManager.shared.calendarAccessStatus == .granted || redraw
        let imageName = calAccessGranted  ? "calendar" : "calendar.badge.exclamationmark"
        
        Image(systemName: imageName)
            .foregroundColor(.calendar)
            .font(.system(size: 43))
            .onReceive(Secretary.shared.$calendarAccessGranted) { redraw = $0 }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSticker()
    }
}

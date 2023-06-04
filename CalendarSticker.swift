//
//  CalendarView.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
//

import SwiftUI

struct CalendarSticker: View {
    let calRatio:CGFloat = 98.0/91.0
    
    var body: some View {
        ZStack {
            let name =  CalendarManager.shared.calendarAccessStatus == .granted ? "calendar" : "calendar.badge.exclamationmark"
            Image(systemName: name)
                .foregroundColor(.calendar)
                .font(.system(size: 43))
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSticker()
    }
}

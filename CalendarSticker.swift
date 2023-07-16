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
    
    @EnvironmentObject private var bubble:Bubble
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if bubble.hasCalendar && bubble.note_.isEmpty {
                let calAccessGranted = CalendarManager.shared.calendarAccessStatus == .granted || redraw
                let imageName = calAccessGranted  ? "calendar" : "calendar.badge.exclamationmark"
                
                Image(systemName: imageName)
                    .foregroundStyle(Color.calendar)
                    .font(.system(size: 43))
                    .onChange(of: secretary.calendarAccessGranted) { redraw = $1 }
            }
        }
    }
}

struct CalendarButton:View {
    @EnvironmentObject private var bubble:Bubble
    var action: () -> ()
    
    var body: some View {
        Button { action() }
    label: { Label { Text(calendarActionName) }
        icon: { Image(systemName: calendarActionImageName) } }
    .tint(calendarActionColor)
    }
    
    private var calendarActionName:String {
        guard CalendarManager.shared.calendarAccessStatus != .revoked else { return "No Access" }
        return bubble.hasCalendar ? "Cal OFF" : "Cal ON"
    }
    
    private var calendarActionImageName:String {
        guard CalendarManager.shared.calendarAccessStatus != .revoked else { return "calendar.badge.exclamationmark"
        }
        return bubble.hasCalendar ? "calendar" : "calendar"
    }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}

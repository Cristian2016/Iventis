//
//  CalendarEventCreatedConfirmation.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.02.2023.
//

import SwiftUI
import MyPackage

struct CalendarEventCreatedConfirmation: View {
    @Environment(Secretary.self) private var secretary
    
    private var show:Bool { secretary.confirm_CalEventCreated != nil }
    
    var body: some View {
        ZStack { if show { ConfirmView(content: .eventCreated) }}
    }
}

struct CalendarEventRemovedConfirmation: View {
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            let show = secretary.confirm_CalEventRemoved != nil
            if show {
                ConfirmView(content: .eventRemoved)
            }
        }
    }
}

///when user taps finished timer, this alert will show
struct CloseSessionAlert: View {
    @Environment(Secretary.self) private var secretary
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show { ConfirmView(content: .eventRemoved) }
        }
        .onChange(of: secretary.showAlert_closeSession) { show = $1 }
    }
}

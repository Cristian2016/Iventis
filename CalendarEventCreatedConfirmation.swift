//
//  CalendarEventCreatedConfirmation.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.02.2023.
//

import SwiftUI
import MyPackage

struct CalendarEventCreatedConfirmation: View {
    private let secretary = Secretary.shared
    @State private var confirm_CalEventCreated:Int64?
    
    var body: some View {
        ZStack {
            if confirm_CalEventCreated != nil {
                ConfirmView(content: .eventCreated)
            }
        }
        .onReceive(secretary.$confirm_CalEventCreated) {
            confirm_CalEventCreated = $0
        }
    }
}

struct CalendarEventRemovedConfirmation: View {
    private let secretary = Secretary.shared
    @State private var confirm_CalEventRemoved:Int64?
    
    var body: some View {
        ZStack {
            if confirm_CalEventRemoved != nil {
                ConfirmView(content: .eventRemoved)
            }
        }
        .onReceive(secretary.$confirm_CalEventRemoved) {
            confirm_CalEventRemoved = $0
        }
    }
}

///when user taps finished timer, this alert will show
struct CloseSessionAlert: View {
    private let secretary = Secretary.shared
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                ConfirmView(content: .eventRemoved)
            }
        }
        .onReceive(secretary.$showAlert_closeSession) { show = $0 }
    }
}

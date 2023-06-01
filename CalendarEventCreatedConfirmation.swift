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
                ConfirmView1(content: .eventCreated)
                    .transition(.asymmetric(insertion: .scale(scale: 0.4), removal: .opacity))
            }
        }
        .onReceive(secretary.$confirm_CalEventCreated) { value in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                confirm_CalEventCreated = value
            }
        }
    }
}

struct CalendarEventRemovedConfirmation: View {
    private let secretary = Secretary.shared
    @State private var confirm_CalEventRemoved:Int64?
    
    var body: some View {
        ZStack {
            if confirm_CalEventRemoved != nil {
                ConfirmView1(content: .eventRemoved)
                    .transition(.asymmetric(insertion: .scale(scale: 0.4), removal: .opacity))
            }
        }
        .onReceive(secretary.$confirm_CalEventRemoved) { value in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                confirm_CalEventRemoved = value
            }
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

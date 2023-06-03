//
//  WarningLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.06.2023.
//

import SwiftUI
import MyPackage

struct WarningLabel: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, Color.label)
                        .font(.system(size: 40))
                    Text("Calendar Access Denied")
                        .font(.system(size: 30))
                    Divider()
                    Text("Settings App > Fused > Calendars")
                        .font(.system(size: 22))
                    Text("*Grant Calendar Access:\nOpen 'Settings App' on your device > Scroll down to 'Fused' and tap it > Make sure 'Calendars' Toggle is ON*")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                    Image("calToggle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                }
                .padding()
                .frame(width: 370)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .onReceive(Secretary.shared.$showCalendarAccessDeniedWarning) { show = $0 }
    }
}

struct WarningLabel_Previews: PreviewProvider {
    static var previews: some View {
        WarningLabel()
    }
}

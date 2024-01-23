//
//  WarningLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.06.2023.
//

import SwiftUI
import MyPackage

struct CalAccessDeniedAlert: View {
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if secretary.showCalendarAccessDeniedWarning {
                ZStack {
                    Background(.dark())
                        .onTapGesture { secretary.showCalendarAccessDeniedWarning = false }
                    
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .label2)
                            .font(.system(size: 40))
                        Text("Calendar Access Denied")
                            .font(.system(size: 30))
                        Divider()
                        Text("Settings App > Iventis > Calendars > Full Access")
                            .font(.system(size: 22))
                        Text("*In 'Settings App' on your device > Scroll down to 'Iventis' > 'Calendars' > Choose 'Full Access'*")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                        Image("calToggle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .padding()
                    .frame(width: 360)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
}

struct WarningLabel_Previews: PreviewProvider {
    static var previews: some View {
        CalAccessDeniedAlert()
    }
}

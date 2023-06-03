//
//  WarningLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.06.2023.
//

import SwiftUI
import MyPackage

struct WarningLabel: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar.badge.exclamationmark")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.red, .black)
                .font(.system(size: 40))
            Text("Calendar Access Denied")
                .font(.system(size: 30))
            Text("Settings App > Fused > Calendars")
                .font(.system(size: 22))
            Text("Open Settings App on your device. Scroll down to 'Fused' and tap it. Toggle must be ON")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
            Image("calToggle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
        }
    }
}

struct WarningLabel_Previews: PreviewProvider {
    static var previews: some View {
        WarningLabel()
    }
}

//
//  InfoView2.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.11.2023.
//

import SwiftUI

extension DurationPickerOverlay {
    struct InfoView2:View {
        let manager:DurationPickerOverlay.Manager
        
        var body: some View {
            HStack {
                ClearText()
                SaveText()
                    .environment(manager)
            }
            .font(.system(size: 18))
        }
    }
    
    struct SaveText: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(DurationPickerOverlay.Manager.self) var manager
        
        var body: some View {
            let isLight = colorScheme == .light
            VStack(spacing: 6) {
                Text(manager.isDurationValid ? "Save" : "Dismiss")
                Image(isLight ? "saveText" : "saveTextDark")
                    .resizable()
                    .modifier(ImageModifier())
            }
        }
    }
}

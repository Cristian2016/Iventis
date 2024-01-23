//
//  DPDisplay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import SwiftUI
import MyPackage

extension DurationPickerOverlay {
    struct Display: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        var reason:ViewModel.DurationPicker.Reason
        var manager:DurationPickerOverlay.Manager
         
        @State private var showSaveAction = false
                
        // MARK: - Body
        var body: some View {
            Color.background.opacity(.Opacity.basicallyTransparent)
                .frame(height: .Overlay.displayHeight)
                .overlay {
                    if manager.digits.isEmpty { 
                        welcomeText
                            .foregroundStyle(.secondary)
                            .font(.system(size: 34, design: .rounded))
                    }
                    else { durationComponentsStack }
                }
                .onChange(of: manager.isDisplayEmpty) { if $1 { clearDisplay() } }
                .onChange(of: manager.isDurationValid) { showSaveAction = $1 ? true : false }
                .minimumScaleFactor(0.4)
        }
        
        // MARK: - Lego
        private var welcomeText:some View {
            switch reason {
                case .changeToTimer(_):
                    FlipText(input: .changeToTimer)
                case .createTimer(_):
                    FlipText(input: .createTimer)
                case .editExistingTimer(_):
                    FlipText(input: .editTimer)
            }
        }
        
        private var durationComponentsStack:some View {
            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(manager.hr)
                    Text("h")
                        .font(.system(size: 20, weight: .semibold))
                }
                
                if !manager.min.isEmpty { 
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(manager.min)
                        Text("m")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                if !manager.sec.isEmpty { 
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(manager.sec)
                        Text("s")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                SmallCheckmark(manager: manager)
            }
            .font(.displayFont)
            .padding([.leading, .trailing], 4)
        }
        
        // MARK: -
        private func clearDisplay() {
            manager.reset()
        }
    }
}

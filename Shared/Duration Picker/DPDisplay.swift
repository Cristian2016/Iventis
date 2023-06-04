//
//  DPDisplay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import SwiftUI
import MyPackage

extension DurationPickerView {
    struct Display: View {
        private let  viewModel = TheFlipText.ViewModel(delay: .now() + 3, timerRepeatFrequency: 5, repeatCount: 10)
        let reason:Secretary.DurationPickerReason
        let dismiss: () -> ()
        
        @State private var showSaveAction = false
        
        init(_ reason:Secretary.DurationPickerReason, dismiss: @escaping() -> ()) {
            self.reason = reason
            self.dismiss = dismiss
        }
        
        let manager = DurationPickerView.Manager.shared
        
        @State private var hr = String()
        @State private var min = String()
        @State private var sec = String()
        
        var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 80)
                        .overlay {
                            if hr.isEmpty { welcomeText }
                            else { durationComponentsStack }
                        }
                    
                    Color.ultraLightGray1
                        .frame(width: 200, height: 1)
                    
                    Color.clear
                        .frame(height: 30)
                        .overlay { infoText }
                }
            }
            .allowsHitTesting(false)
            .onReceive(manager.$component) { received(component: $0) }
            .onReceive(manager.$displayIsEmpty) { if $0 { clearDisplay() }}
            .onReceive(manager.$isDurationValid) { showSaveAction = $0 ? true : false }
        }
        
        func setWelcomeText() -> String {
            let welcomeText:String
            
            switch reason {
                case .createTimer(_):
                    welcomeText = "Enter Duration"
                case .editExistingTimer(_):
                    welcomeText = "New Duration"
                case .changeToTimer(_):
                    welcomeText = "Enter Duration"
                case .none:
                    welcomeText = ""
            }
            return welcomeText
        }
        
        // MARK: - Lego
        private var welcomeText:some View { FlipText(input: .createTimer) }
        
        @ViewBuilder
        private var infoText:some View {
            if manager.digits.isEmpty {
                TheFlipText(.noInput)
            }
            else {
                TheFlipText( manager.digits.count%2 == 0 ? .save : .dismiss)
            }
        }
        
        private var durationComponentsStack:some View {
            HStack {
                component(hr, \.hr)
                if !min.isEmpty { component(min, \.min) }
                if !sec.isEmpty { component(sec, \.sec) }
                DPCheckmark()
            }
            .padding([.leading, .trailing], 4)
            .minimumScaleFactor(0.1)
        }
        
        private func component(_ value:String, _ keyPath:KeyPath<Display, String>) -> some View {
            var abbreviation:String!
            switch keyPath {
                case \.hr: abbreviation = "h"
                case \.min: abbreviation = "m"
                case \.sec: abbreviation = "s"
                default: abbreviation = ""
            }
            
            return HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 65))
                Text(abbreviation)
                    .font(.system(size: 20, weight: .semibold))
            }
            .fontDesign(.rounded)
        }
        
        // MARK: -
        private func clearDisplay() {
            hr = ""
            min = ""
            sec = ""
        }
        
        private func received(component:Manager.Component?) {
            guard let component = component else { return }
            
            switch component {
                case .hr(let hr): self.hr = hr
                case .min(let min): self.min = min
                case .sec(let sec): self.sec = sec
            }
        }
    }
}

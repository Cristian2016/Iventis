//
//  DPDisplay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import SwiftUI

extension DurationPickerView {
    struct Display: View {
        let manager = DurationPickerView.Manager.shared
        
        @State private var hr = String()
        @State private var min = String()
        @State private var sec = String()
        
        let dismiss: () -> ()
            
        var body: some View {
            ZStack {
                if hr.isEmpty { welcomeText }
                else { durationComponentsStack }
            }
            .frame(height: 100)
            .background()
            .allowsHitTesting(false)
            .onReceive(manager.$component) { received(component: $0) }
            .onReceive(manager.$displayIsEmpty) { if $0 { clearDisplay() }}
        }
        
        // MARK: - Lego
        private var welcomeText:some View {
            VStack {
                Text("Enter Duration")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .layoutPriority(1)
                
                Text("48 hours max")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }
            .padding([.leading, .trailing], 4)
            .minimumScaleFactor(0.1)
        }
        
        private var durationComponentsStack:some View {
            HStack {
                durationComponentView(hr, \.hr)
                if !min.isEmpty { durationComponentView(min, \.min) }
                if !sec.isEmpty { durationComponentView(sec, \.sec) }
            }
            .padding([.leading, .trailing], 4)
            .minimumScaleFactor(0.1)
        }
        
        private func durationComponentView(_ value:String, _ keyPath:KeyPath<Display, String>) -> some View {
            var abbreviation:String!
            switch keyPath {
                case \.hr: abbreviation = "h"
                case \.min: abbreviation = "m"
                case \.sec: abbreviation = "s"
                default: abbreviation = ""
            }
            
            return HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 75, design: .rounded))
                Text(abbreviation)
                    .font(.system(size: 20, design: .rounded))
                    .fontWeight(.bold)
            }
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

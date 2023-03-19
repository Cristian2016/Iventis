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
            .onReceive(manager.$digits) { updateComponents($0) }
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
                    .font(.system(size: 80, design: .rounded))
                    .minimumScaleFactor(0.1)
                Text(abbreviation)
                    .font(.system(size: 20, design: .rounded))
                    .fontWeight(.bold)
            }
        }
        
        // MARK: -
        private func updateComponents(_ digits:[Int]) {
            switch digits.count {
                case 0:
                    hr = ""
                    min = ""
                    sec = ""
                case 1:
                    hr = String(digits[0]) + "⎽"
                case 2:
                    hr = digits.reduce("") { String($0) + String($1) }
                case 3:
                    min = String(digits[2]) + "⎽"
                case 4:
                    min = digits.dropFirst(2).reduce("") { String($0) + String($1) }
                case 5:
                    sec = String(digits[4]) + "⎽"
                case 6:
                    sec = digits.dropFirst(4).reduce("") { String($0) + String($1) }
                default: break
            }
        }
    }
}

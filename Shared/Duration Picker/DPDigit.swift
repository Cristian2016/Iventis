//
//  DPDigit.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//1 gestures tap (send title to manager) and longPress (x digit only clear display)

import SwiftUI
import MyPackage

extension DurationPickerOverlay {
    struct Digit:View {
        private let digit:String
        private let tricolor:Color.Tricolor
        
        @State private var isTapped = false
        
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        
        private var isHidden:Bool {
            (manager.notAllowedCharacters == .allDigits && digit != "✕") ? true : false
        }
        
        private var isDisabled:Bool {
            manager.notAllowedCharacters.contains(digit.unicodeScalars.first!) ? true : false
        }
        
        let manager:Manager
        
        init?(_ digit: String, _ tricolor: Color.Tricolor?, _ manager: Manager) {
            guard let tricolor = tricolor else { return nil }
            
            self.digit = digit
            self.tricolor = tricolor
            self.manager = manager
        }
        
        private var fillColor:Color {
            if digit == "✕" {
                return isDisabled ? .background.opacity(0.4) : .red
            } else {
                return isDisabled ? .background.opacity(0.4) : .background
            }
        }
        
        var body: some View {
            shape
                .foregroundStyle(fillColor)
                .overlay {
                    Text(digit == "*" ? "00" : digit)
                        .font(.digitFont)
                        .minimumScaleFactor(0.01)
                        .foregroundStyle(digitColor)
                }
                .onTapGesture { didTapDigit() } //1
                .onLongPressGesture { clearDisplay() } //1
                .opacity(isTapped || isHidden ? .Opacity.basicallyTransparent : .Opacity.opaque)
        }
        
        private var digitColor:Color {
            isDisabled ? .disabledDigit : digit == "✕" ? .white : .label
        }
        
        // MARK: - Intents
        private func didTapDigit() {
            if isDisabled { return }
            
            //User Feedback
            UserFeedback.singleHaptic(.light)
            withAnimation(.easeIn(duration: 0.05)) { isTapped = true }
            delayExecution(.now() + 0.05) { isTapped = false }
            
            switch digit {
                case "✕" : manager.removelastDigit()
                case "*" : manager.addDoubleZero()
                default : manager.addToDigits(Int(digit)!)
            }
        }
        
        private func clearDisplay() {
            if digit == "✕" {
                UserFeedback.singleHaptic(.heavy)
                manager.reset()
            }
        }
        
        @ViewBuilder
        private var shape:some View {
            Capsule()
        }
    }
}

//
//  DPDigit.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//1 gestures tap (send title to manager) and longPress (x digit only clear display)

import SwiftUI
import MyPackage

extension DurationPickerView {
    struct Digit:View {
        let manager = Manager.shared
        
        @State private var isTapped = false
        @State private var disabled = false
        @State private var hidden = false
        
        let digit:String
        let tricolor:Color.Tricolor
        
        init(_ digit: String, _ tricolor: Color.Tricolor) {
            self.digit = digit
            self.tricolor = tricolor
        }
        
        var body: some View {
            shape
                .frame(minHeight: 52)
                .overlay {
                    Text(digit == "*" ? "00" : digit)
                        .font(.system(size: 50, design: .rounded))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                        .opacity(disabled ? 0.5 : 1.0)
                }
                .onTapGesture { didTapDigit() } //1
                .onLongPressGesture { clearDisplay() } //1
                .opacity(isTapped || hidden ? 0 : 1.0)
                .disabled(disabled ? true : false)
                .onReceive(manager.$notAllowedCharacters) {
                    if $0 == .allDigits && digit != "✕" {
                        hidden = true
                        return
                    } else {
                        hidden = false
                    }
                    disabled = $0.contains(digit.unicodeScalars.first!) ? true : false
                }
        }
        
        // MARK: - Lego
        @ViewBuilder
        private var shape:some View {
            switch digit {
                case "✕":
                    vRoundedRectangle(corners: .bottomRight, radius: 32)
                        .fill(disabled ? Color.Bubble.clearButtonRed.hr : Color.Bubble.clearButtonRed.sec)
                case "*":
                    vRoundedRectangle(corners: .bottomLeft, radius: 32)
                        .fill(disabled ? tricolor.hr : tricolor.sec)
                default:
                    Rectangle()
                        .fill(disabled ? tricolor.hr : tricolor.sec)
            }
        }
        
        // MARK: - Intents
        private func didTapDigit() {
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
                manager.removeAllDigits()
            }
        }
    }
}

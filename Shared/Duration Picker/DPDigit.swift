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
        
        let title:String
        let tricolor:Color.Tricolor
        
        var body: some View {
            shape
                .overlay {
                    Text(title == "*" ? "00" : title)
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
                    if $0 == .allDigits && title != "✕" {
                        hidden = true
                        return
                    } else {
                        hidden = false
                    }
                    disabled = $0.contains(title.unicodeScalars.first!) ? true : false
                }
        }
        
        // MARK: - Lego
        @ViewBuilder
        private var shape:some View {
            switch title {
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
        
        // MARK: -
        private func didTapDigit() {
            //User Feedback
            UserFeedback.singleHaptic(.light)
            withAnimation(.easeIn(duration: 0.1)) { isTapped = true }
            delayExecution(.now() + 0.12) { isTapped = false }
            
            switch title {
                case "✕" : manager.removelastDigit()
                case "*" : manager.addDoubleZero()
                default : manager.addToDigits(Int(title)!)
            }
        }
        
        private func clearDisplay() {
            if title == "✕" {
                UserFeedback.singleHaptic(.heavy)
                manager.removeAllDigits()
            }
        }
    }
}

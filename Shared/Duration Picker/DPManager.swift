//
//  DPManager.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//1 create bubble.timer of this color and this many seconds as initialClock

import SwiftUI
import MyPackage

extension DurationPickerOverlay {
    @Observable class Manager {
        typealias Characters = CharacterSet
        let matrix = [36_000, 3600, 600, 60, 10, 1]
        
        // MARK: - Observed properties (7)
        var hr = ""
        var min = ""
        var sec = ""
        
        var isDisplayEmpty:Bool { digits.isEmpty }
        var isDurationValid = false
        var digits = [Int]() {didSet{ if !digits.isEmpty { updateUI() }}}
        var notAllowedCharacters = Characters(charactersIn: "56789✕")
        
        // MARK: -
        ///updates both display and digitsGrid
        private func updateUI() {
            let digits = self.digits
            
            self.charactersToDisable() //update digitsGrid
            
            DispatchQueue.global().async {
                let isDurationValid = digits.count%2 == 0 && digits.reduce(0) { $0 + $1 } != 0
                
                self.isDurationValid = isDurationValid
                
                switch digits.count {
                    case 1:
                        let result = String(digits.first!) + "⎽"
                        self.hr = result
                    case 2:
                        let result = digits.reduce("") { String($0) + String($1) }
                        self.hr = result
                        self.min = ""
                    case 3:
                        let result = String(digits.last!) + "⎽"
                        self.min = result
                    case 4:
                        let result = digits.dropFirst(2).reduce("") { String($0) + String($1) }
                        self.min = result
                        self.sec = ""
                    case 5:
                        let result = String(digits.last!) + "⎽"
                        self.sec = result
                    case 6:
                        let result = String(digits[4]) + String(digits[5])
                        self.sec = result
                    default:
                        break
                }
            }
        }
        
        // MARK: - Public API
        func addToDigits(_ value:Int) {
            digits.append(value)
        }
        
        func addDoubleZero() {
            digits.append(contentsOf: [0,0])
        }
        
        func removelastDigit() { if !digits.isEmpty { digits.removeLast() }}
        
        func reset() {
            digits = []
            hr = ""
            min = ""
            sec = ""
            isDurationValid = false
            notAllowedCharacters = Characters(charactersIn: "56789✕")
        }
        
        ///if duration is valid, a timer will be created and then DPV dismissed. If duration not valid, silently dismiss DPV
        func shouldComputeInitialClock(color:String) {
            guard !digits.isEmpty else { return }
            let digitsCopy = digits
            
            DispatchQueue.global().async {
                //make sure the entered digits are valid
                let sum = digitsCopy.reduce(0) { $0 + $1 }
                let validDuration = digitsCopy.count%2 == 0 && sum != 0
                
                //make sure digits are valid
                guard validDuration else { return }
                
                //digits are valid
                UserFeedback.singleHaptic(.medium)
                
                //compute duration [initialClock] as total seconds
                let initialClock = zip(digitsCopy, self.matrix).reduce(0) { $0 + $1.0 * $1.1 }
                
                //ask viewModel to create timer of color and initialClock
                self.askViewModelToCreateTimer(with:color, and:initialClock)
            }
        }
        
        func shouldEditDuration(_ bubble:Bubble) {
            let digitsCopy = digits
            
            DispatchQueue.global().async {
                let sum = digitsCopy.reduce(0) { $0 + $1 }
                let validDuration = digitsCopy.count%2 == 0 && sum != 0
                
                //make sure entered duration is valid
                guard validDuration else { return }
                
                //compute duration
                let initialClock = zip(digitsCopy, self.matrix).reduce(0) { $0 + $1.0 * $1.1 }
                
                DispatchQueue.main.async {
                    self.askViewModelToEditDuration(for: bubble, initialClock)
                }
            }
        }
        
        var userFriendlyDuration:String {
            let result = zip(digits, self.matrix).reduce(0) { $0 + $1.0 * $1.1 }
            return Float(result).timerTitle
        }
        
        // MARK: -
        private func askViewModelToCreateTimer(with color:String, and initialClock: Int) {
            let info : [String : Any] = ["color" : color, "initialClock" : initialClock]
            NotificationCenter.default.post(name: .createTimer, object: nil, userInfo: info)
        } //
        
        private func askViewModelToEditDuration(for bubble:Bubble, _ initialClock:Int) {
            let info : [String : Any] = ["rank" : bubble.rank, "initialClock" : initialClock]
            NotificationCenter.default.post(name: .editTimerDuration, object: self, userInfo: info)
        }
        
        public func charactersToDisable() {
            if digits == [4,8] {
                notAllowedCharacters = .allDigits
                return
            }
            if digits == [0,0,0,0,0] {
                notAllowedCharacters = Characters(charactersIn: "0*")
                return
            }
            if digits == [0,0,0,0] {
                notAllowedCharacters = (Characters(charactersIn: "6789*"))
                return
            }
            
            switch digits.count {
            case 0: notAllowedCharacters = Characters(charactersIn: "56789✕")
            case 1, 3, 5:
                    notAllowedCharacters = digits == [4] ? Characters(charactersIn: "9*") : Characters(charactersIn: "*")
            case 2:
                    notAllowedCharacters = Characters(charactersIn: "6789")
            case 4:
                    notAllowedCharacters = Characters(charactersIn: "6789")
            case 6:
                    notAllowedCharacters = .allDigits
            default:
                    notAllowedCharacters = Characters(charactersIn: "✕")
            }
        }
    }
}

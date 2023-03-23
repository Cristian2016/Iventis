//
//  DPManager.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//1 create bubble.timer of this color and this many seconds as initialClock

import SwiftUI
import MyPackage

extension DurationPickerView {
    class Manager {
        typealias Characters = CharacterSet
        let matrix = [36_000, 3600, 600, 60, 10, 1]
        
        ///updates both display and digitsGrid
        private func updateUI() {
            let count = digits.count
            let digits = self.digits
            
            self.charactersToDisable() //update digitsGrid
            
            DispatchQueue.global().async {
               let isDurationValid = count%2 == 0 && digits.reduce(0) { $0 + $1 } != 0
                
                DispatchQueue.main.async {
                    self.isDurationValid = isDurationValid
                }
                
                switch count {
                    case 0:
                        DispatchQueue.main.async { self.displayIsEmpty = true }
                    case 1:
                        let result = String(digits.first!) + "⎽"
                        DispatchQueue.main.async { self.component = .hr(result) }
                    case 2:
                        let result = digits.reduce("") { String($0) + String($1) }
                        DispatchQueue.main.async {
                            self.component = .hr(result)
                            self.component = .min("")
                        }
                    case 3:
                        let result = String(digits.last!) + "⎽"
                        DispatchQueue.main.async { self.component = .min(result) }
                    case 4:
                        let result = digits.dropFirst(2).reduce("") { String($0) + String($1) }
                        DispatchQueue.main.async {
                            self.component = .min(result)
                            self.component = .sec("")
                        }
                    case 5:
                        let result = String(digits.last!) + "⎽"
                        DispatchQueue.main.async { self.component = .sec(result)}
                    case 6:
                        let result = String(digits[4]) + String(digits[5])
                        DispatchQueue.main.async { self.component = .sec(result) }
                    default:
                        break
                }
            }
        }
        
        @Published var digits = [Int]() {didSet{ updateUI() }}
        @Published var notAllowedCharacters = Characters(charactersIn: "56789✕")
        @Published var component:Component?
        @Published var displayIsEmpty = false //when true display will be cleared
        @Published var isDurationValid = false
        
        struct DisplayComponents {
            let hr:String
            let min:String
            let sec:String
        }
        
        // MARK: - Public API
        static let shared = Manager()
        
        func addToDigits(_ value:Int) {
            digits.append(value)
        }
        
        func addDoubleZero() {
            digits.append(contentsOf: [0,0])
        }
        
        func removelastDigit() { digits.removeLast() }
        
        func removeAllDigits() { digits = [] }
        
        ///if duration is valid, a timer will be created and then DPV dismissed. If duration not valid, silently dismiss DPV
        func shouldComputeInitialClock(color:String) {
            let digitsCopy = digits
            
            DispatchQueue.global().async {
                //make sure the entered digits are valid
                let sum = digitsCopy.reduce(0) { $0 + $1 }
                let condition = digitsCopy.count%2 == 0 && sum != 0
                
                guard condition else { //digits are not valid
                    Secretary.shared.topMostView = .palette
                    return
                }
                
                //digits are valid
                UserFeedback.singleHaptic(.medium)
                
                //compute duration [initialClock] as total seconds
                let initialClock = zip(digitsCopy, self.matrix).reduce(0) { $0 + $1.0 * $1.1 }
                
                //ask viewModel to create timer of color and initialClock
                self.askViewModelToCreateTimer(with:color, and:initialClock)
                
                //dismiss palette also
                DispatchQueue.main.async {
                    withAnimation {
                        Secretary.shared.showPaletteView = false
                    }
                }
            }
        }
        
        // MARK: -
        private func askViewModelToCreateTimer(with color:String, and initialClock: Int) {
            let info : [String : Any] = ["color" : color, "initialClock" : initialClock]
            NotificationCenter.default.post(name: .createTimer, object: nil, userInfo: info)
        } //
        
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
        
        // MARK: -
        private init() {
//            print(#function, " Manager")
        }
        
        // MARK: -
        enum Component {
            case hr(String)
            case min(String)
            case sec(String)
        }
    }
}

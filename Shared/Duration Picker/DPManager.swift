//
//  DPManager.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import Foundation

extension DurationPickerView {
    class Manager {
        typealias Characters = CharacterSet
        
        @Published var digits = [Int]() {didSet{ charactersToDisable() }}
        @Published var notAllowedCharacters = Characters(charactersIn: "56789✕")
        
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
        
        // MARK: -
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
        private init() { }
    }
}

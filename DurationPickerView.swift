//
//  DPV.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.03.2023.
// DurationPickerView
// Pickers https://www.youtube.com/watch?v=2pSDE56u2F0
//1 self.color:Color? because self will appear when the user has chosen a color for the timer to be created. self will init with no values

import SwiftUI
import MyPackage

struct DurationPickerView: View {
    private let digits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["*", "0", "✕"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    let manager = Manager.shared
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var tricolor:Color.Tricolor? //1
    @State private var bubble:Bubble?
    
    @State private var hr:String?
    @State private var min:String?
    @State private var sec:String?
    
    let gridSpacing = CGFloat(1)
    
    private var swipeToClearDisplay:some Gesture {
        DragGesture(minimumDistance: 4)
            .onEnded { _ in clearDisplay() }
    }
    
    private func clearDisplay() {
        manager.removeAllDigits()
    }
    
    var body: some View {
        ZStack {
            if tricolor != nil {
                translucentBackground
                    .gesture(swipeToClearDisplay)
                    .onTapGesture { dismiss() }
                
                ZStack {
                    VStack(spacing: 0) {
                        DPVDisplay { dismiss() }
                        digitsGrid
                    }
                    .offset(y: -4)
                    .padding([.leading, .trailing, .bottom])
                    .padding(4)
                    .background { background }
                }
                .padding(4)
            }
        }
        .onReceive(Secretary.shared.$durationPickerMode) { output in
            if let mode = output {
                switch mode {
                    case .create(let tricolor):
                        self.tricolor = tricolor
                    case .edit(let bubble):
                        self.bubble = bubble
                }
            }
        }
    }
    
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 5)
            .onEnded {
                let xTranslation = $0.translation.width
                
                if xTranslation > 0 {
                    print("advance right")
                } else {
                    print("advance left")
                }
            }
    }
    
    // MARK: - Lego
    private var translucentBackground:some View {
        Rectangle()
            .fill(.thinMaterial)
            .ignoresSafeArea()
    }
    
    private var background: some View {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
            .fill(.background)
            .padding([.leading, .trailing])
            .standardShadow()
            .onTapGesture { dismiss() }
            .gesture(swipeToClearDisplay)
    }
    
    private func componentView(_ value:String, _ keyPath:KeyPath<DurationPickerView, String>) -> some View {
        
        var abbreviation:String = "ok"
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
                .fontWeight(.medium)
        }
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(digits, id: \.self) { subarray in
                GridRow {
                    ForEach(subarray, id: \.self) { title in
                        Digit(title: title, tricolor: self.tricolor!)
                    }
                }
            }
        }
        .background()
        .gesture(swipe)
    }
    
    // MARK: -
    func dismiss() {
        self.tricolor = nil
    }
}

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
                .opacity(isTapped || hidden ? 0 : 1.0)
                .onTapGesture {
                    UserFeedback.singleHaptic(.light)
                    withAnimation(.easeIn(duration: 0.1)) {
                        isTapped = true
                    }
                    delayExecution(.now() + 0.12) {
                        isTapped = false
                    }
                    
                    switch title {
                        case "✕" : manager.removelastDigit()
                        case "*" : manager.addDoubleZero()
                        default : manager.addToDigits(Int(title)!)
                    }
                                    }
                .onLongPressGesture {
                    if title == "✕" {
                        manager.removeAllDigits()
                        UserFeedback.singleHaptic(.heavy)
                    }
                }
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
    }
}

extension DurationPickerView {
    class Manager {
        typealias Characters = CharacterSet
        
        @Published var digits = [Int]() {didSet{ charactersToDisable() }}
        
        struct DisplayComponents {
            let hr:String
            let min:String
            let sec:String
        }
        
        @Published var notAllowedCharacters = Characters(charactersIn: "56789✕")
        
        
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

struct DPV_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView()
    }
}

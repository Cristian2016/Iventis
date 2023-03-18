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
    private let digits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["00", "0", "✕"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    let manager = Manager.shared
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var color:Color? //1
    @State private var bubble:Bubble?
    
    @State private var hr:String = "0"
    @State private var min:String = "0"
    @State private var sec:String = "0"
    
    let gridSpacing = CGFloat(1)
    
    var body: some View {
        ZStack {
            if color != nil {
                translucentBackground
                    .onTapGesture { dismiss() }
                
                ZStack {
                    VStack(spacing: 0) {
                        display
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
                    case .create(let color):
                        self.color = color
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
    }
    
    private var display: some View {
        HStack {
            componentView(hr, \.hr)
            componentView(min, \.min)
            componentView(sec, \.sec)
        }
        .frame(height: 100)
        .background()
        .onTapGesture { dismiss() }
        .padding([.leading, .trailing], 4)
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
                        Digit(title: title, color: self.color!)
                    }
                }
            }
        }
        .gesture(swipe)
    }
    
    // MARK: -
    func dismiss() {
        self.color = nil
    }
}

extension DurationPickerView {
    struct Digit:View {
        let manager = Manager.shared
        
        @State private var isTapped = false
        @State private var disabled = false
        
        let title:String
        let color:Color
        
        @ViewBuilder
        private var shape:some View {
            switch title {
                case "✕":
                    vRoundedRectangle(corners: .bottomRight, radius: 32)
                        .fill(.red)
                case "00":
                    vRoundedRectangle(corners: .bottomLeft, radius: 32)
                        .fill(color)
                default:
                    Rectangle()
                        .fill(color)
            }
        }
        
        var body: some View {
            shape
                .opacity(disabled ? 0.3 : 1.0)
                .overlay {
                    Text(title)
                        .font(.system(size: 50, design: .rounded))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                }
                .opacity(isTapped ? 0.2 : 1.0)
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
                        case "00" : manager.addDoubleZero()
                        default : manager.addToDigits(Int(title)!)
                    }
                                    }
                .onLongPressGesture {
                    if title == "✕" { manager.removeALlDigits() }
                }
                .disabled(disabled ? true : false)
                .onReceive(manager.$notAllowedCharacters) {
                    if title.unicodeScalars.count == 1 {
                        if $0.contains(title.unicodeScalars.first!) {
                            disabled = true
                        } else {
                            disabled = false
                        }
                    }
                }
        }
    }
    
    struct Display:View {
//        @State private var
        var body: some View {
            Text("")
        }
    }
}

extension DurationPickerView {
    class Manager {
        typealias Characters = CharacterSet
        
        private(set) var digits = [Int]() {didSet{
            print("digits string \(digits)")
        }}
        
        @Published var notAllowedCharacters = Characters(charactersIn: "56789✕")
        
//        @Published var display =
        
        // MARK: - Public API
        static let shared = Manager()
        
        func addToDigits(_ value:Int) {
            digits.append(value)
        }
        
        func addDoubleZero() {
            digits.append(contentsOf: [0,0])
        }
        
        func removelastDigit() { digits.removeLast() }
        
        func removeALlDigits() { digits = [] }
        
        // MARK: -
//        public func charactersToDisable(for digits:String?) -> Characters {
//            guard let string = string else {return Characters()}
//
//            if (string == "48") {return Characters(charactersIn: "0123456789").union(doubleZero)}
//            if (string == "00000") {return Characters(charactersIn: "0").union(doubleZero)}
//            if (string == "0000") {return doubleZero.union(Characters(charactersIn: "6789"))}
//
//            switch string.count {
//            case 0: return Characters(charactersIn: "56789✕")
//            case 1, 3, 5:
//                return (string == "4") ? Characters(charactersIn: "9").union(doubleZero) : Characters().union(doubleZero)
//            case 2: return Characters(charactersIn: "6789")
//            case 4: return Characters(charactersIn: "6789")
//            case 6: return Characters(charactersIn: "0123456789").union(doubleZero)
//            default: return Characters(charactersIn: "✕")
//            }
//        }
        
        // MARK: -
        private init() { }
    }
}

struct DPV_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView()
    }
}

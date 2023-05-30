//
//  TheFlipText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.05.2023.
//

import SwiftUI
import MyPackage

struct TheFlipText: View {
    let input:Input //lines to display
    let flipCount:Int
    let textStyle:TextStyle
    private let  viewModel = ViewModel(delay: .now() + 3, timerRepeatFrequency: 5, repeatCount: 10)
    @State private var viewToShowIndex = 0
    
    var body: some View {
        let center = NotificationCenter.Publisher(center: .default, name: .flipTextSignal)
        let lines = input.lines
        
        ZStack {
            ForEach(lines, id: \.self) { line in
                let currentIndex = lines.firstIndex(of: line)!
                
                if currentIndex == viewToShowIndex {
                    Text(line)
                        .font(.system(size: .minFontSize))
                        .transition(.scale.combined(with: .opacity))
                        .foregroundColor(.secondary)
                }
            }
        }
        .onReceive(center) { _ in handleSignal() }
    }
    
    init(_ input: Input, flipCount: Int = 2, _ textStyle:TextStyle = .small) {
        self.input = input
        self.flipCount = flipCount
        self.textStyle = textStyle
    }
    
    private func handleSignal() {
        let newIndex = (viewToShowIndex + 1)%input.lines.count
        withAnimation { viewToShowIndex = newIndex }
    }
}

extension TheFlipText {
    struct Input {
        let lines:[LocalizedStringKey]
        
        static let noInput = Input(lines: ["**Dismiss** \(Image.tap) Tap"])
        static let save = Input(lines: ["**Create** \(Image.tap) Tap", "**Clear** \(Image.swipeLeft) Swipe"])
        static let dismiss = Input(lines: ["**Dismiss** \(Image.tap) Tap", "**Clear** \(Image.swipeLeft) Swipe"])
    }
    
    enum TextStyle {
        case small
        case medium
        case big
    }
    
    class ViewModel {
        let delay:DispatchTime
        let timerRepeatFrequency:Double
        let repeatCount:Int
        
        init(delay: DispatchTime, timerRepeatFrequency: Double, repeatCount: Int) {
            self.delay = delay
            self.timerRepeatFrequency = timerRepeatFrequency
            self.repeatCount = repeatCount
            
            bTimer = .init(deadLine: delay, frequency: timerRepeatFrequency, repeatCount: repeatCount)
            bTimer.eventHandler = {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(.flipTextSignal)
                    print("flipTextSignal")
                }
            }
            bTimer.perform(.start)
        }
        
        private let bTimer:bTimer
    }
}

struct TheFlipText_Previews: PreviewProvider {
    static var previews: some View {
        TheFlipText(.dismiss, flipCount: 2)
    }
}

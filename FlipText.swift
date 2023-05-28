//
//  FlipText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.05.2023.
//1 two properties that will be animated. anything before .animation will be animated. opacity will not be animated

import SwiftUI
import MyPackage

struct FlipText: View {
    @State private var isAllowedToFlip = true
    let input:Input
    @State private var index = 0
    
    var body: some View {
        ZStack {
            let lines = input.lines
            let transition = AnyTransition
                .move(edge: .bottom)
                .combined(with: .opacity.combined(with: .scale(scale: 0.2)))
            
            ForEach(lines, id: \.self) { line in
                let currentIndex = lines.firstIndex(of: line)!
                
                if currentIndex == index {
                    Text(line)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .transition(.asymmetric(insertion: .move(edge: .top), removal: transition))
                }
            }
        }
        .onAppear {
            var repeatCount = 5
            
            delayExecution(.now() + 3) {
                Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                    let newIndex = (index + 1)%input.lines.count
                                        
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                        index = newIndex
                    }
                    
                    repeatCount -= 1
                    if repeatCount == 0 { timer.invalidate() }
                }
                .fire()
            }
        }
    }
}

extension FlipText {
    struct Input {
        let lines:[String]
        
        static let createTimer = Input(lines: ["Create Timer", "Enter Duration"])
    }
}

struct FlipText_Previews: PreviewProvider {
    static var previews: some View {
        FlipText(input: .createTimer)
    }
}

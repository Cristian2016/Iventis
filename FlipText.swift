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
            
            ForEach(lines, id: \.self) { line in
                let currentIndex = lines.firstIndex(of: line)!
                
                Text(line)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .zIndex(currentIndex == index ? 1 : 0) //1
                    .offset(y: currentIndex == index ? 0 : -40) //1
                    .animation(.spring(response: 0.8, dampingFraction: 0.5), value: index) //1
                    .opacity(currentIndex == index ? 1 : 0)
            }
        }
        .onAppear {
            delayExecution(.now() + 3) {
                Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    let newIndex = (index + 1)%input.lines.count
                    index = newIndex
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

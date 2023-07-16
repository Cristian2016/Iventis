//
//  FlipText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.05.2023.
//1 two properties that will be animated. anything before .animation will be animated. opacity will not be animated

import SwiftUI
import MyPackage

extension AnyTransition {
    static let removal = {
        let trans = AnyTransition.move(edge: .bottom)
        return trans.combined(with: .opacity.combined(with: .scale(scale: 0.4)))
    }()
}

struct FlipText: View {
    @State private var viewToShowIndex = 0
    
    let input:Input
    
    var body: some View {
        ZStack {
            let lines = input.lines
            
            ForEach(lines, id: \.self) { line in
                let currentIndex = lines.firstIndex(of: line)!
                
                if currentIndex == viewToShowIndex {
                    Text(line)
                        .transition(.asymmetric(insertion: .move(edge: .top), removal: .removal))
                }
            }
        }
        .onAppear {
            var repeatCount = 1
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                let newIndex = (viewToShowIndex + 1)%input.lines.count
                
                withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) { viewToShowIndex = newIndex }
                
                repeatCount -= 1
                if repeatCount == 0 { $0.invalidate() }
            }
        }
    }
}

extension FlipText {
    struct Input {
        let lines:[LocalizedStringKey]
        
        //DurationPicker
        static let createTimer = Input(lines: ["Create Timer", "Enter Duration"])
        static let editTimer = Input(lines: ["Edit Timer", "Enter Duration"])
        static let changeToTimer = Input(lines: ["Switch to Timer", "Enter Duration"])
    }
}

struct FlipText_Previews: PreviewProvider {
    static var previews: some View {
        FlipText(input: .createTimer)
    }
}

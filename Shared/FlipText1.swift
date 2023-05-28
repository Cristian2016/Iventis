//
//  FlipText1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.05.2023.
//

import SwiftUI
import MyPackage

struct FlipText1: View {
    @State private var isAllowedToFlip = true
    let input:Input
    @State private var viewToShowIndex = 0
    
    let removal:AnyTransition = {
        let trans = AnyTransition.move(edge: .trailing)
        return trans.combined(with: .opacity.combined(with: .scale(scale: 0.4)))
    }()
    
    var body: some View {
        ZStack {
            let lines = input.lines
            
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
        .onAppear {
//            if input.lines.count > 1 {
                Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    let newIndex = (viewToShowIndex + 1)%input.lines.count
                    withAnimation { viewToShowIndex = newIndex }
                }
//            }
        }
    }
}

extension LocalizedStringKey:Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("")
    }
}

extension FlipText1 {
    struct Input {
        let lines:[LocalizedStringKey]
        
        static let noInput = Input(lines: ["**Dismiss** \(Image.tap) Tap"])
        static let save = Input(lines: ["**Save** \(Image.tap)", "**Clear** \(Image.swipeLeft)"])
        static let dismiss = Input(lines: ["**Dismiss** \(Image.tap)", "**Clear** \(Image.swipeLeft)"])
    }
}

struct FlipText1_Previews: PreviewProvider {
    static var previews: some View {
        FlipText1(input: .save)
    }
}

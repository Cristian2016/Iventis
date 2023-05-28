//
//  FlipText1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.05.2023.
//

import SwiftUI
import MyPackage

struct FlipText1: View {
    let input:Input
    
    var body: some View {
        HStack {
            let lines = input.lines
            
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(size: .minFontSize))
                    .transition(.scale.combined(with: .opacity))
                    .foregroundColor(.secondary)
            }
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

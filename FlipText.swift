//
//  FlipText.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.05.2023.
//

import SwiftUI
import MyPackage

struct FlipText: View {
    @State private var isAllowedToFlip = true
    let lines = ["Create Timer", "Enter Duration"]
    @State private var index = 0
    
    var body: some View {
        ZStack {
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .zIndex(lines.firstIndex(of: line)! == index ? 1 : 0)
                    .offset(y: lines.firstIndex(of: line)! == index ? 0 : -40)
                    .animation(.spring(response: 0.8, dampingFraction: 0.5), value: index)
                    .opacity(lines.firstIndex(of: line)! == index ? 1 : 0)
            }
        }
        .onAppear {
            delayExecution(.now() + 3) {
                Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    let newIndex = (index + 1)%lines.count
                    index = newIndex
                }
                .fire()
            }
        }
    }
}

struct FlipText_Previews: PreviewProvider {
    static var previews: some View {
        FlipText()
    }
}

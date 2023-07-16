//
//  SymbolCView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.11.2023.
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-animate-sf-symbols
// https://www.google.com/search?client=safari&rls=en&q=SF+symbols+animate+symbol&ie=UTF-8&oe=UTF-8

import SwiftUI

struct SymbolCView: View {
    @State private var bounce = false
    
    var body: some View {
        Button {
        } label: {
            Label("Timer", systemImage: "timer")
        }
        .font(.largeTitle)
        .scaleEffect(x: bounce ? 1.2 : 1, y: bounce ? 1.2 : 1)
        .animation(.bouncy.repeatForever(), value: bounce)
        .onAppear {
            doBounce()
        }
    }
    
    func doBounce() {
        self.bounce = true
    }
}

#Preview {
    SymbolCView()
}

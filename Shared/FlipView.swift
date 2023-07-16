//
//  FlipView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.11.2023.
//

import SwiftUI

//two views only
struct Flip2Views<First:View, Second:View> : View {
    @State private var showFirstView = true
    
    var body: some View {
        ZStack {
            first
                .transition(.asymmetric(insertion: .move(edge: .top), removal: .removal))
                .opacity(showFirstView ? 1 : 0)
            second
                .transition(.asymmetric(insertion: .move(edge: .top), removal: .removal))
                .opacity(showFirstView ? 0 : 1)
        }
        .onAppear {
            var repeatCount = 1
            
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                    showFirstView.toggle()
                }
                
                repeatCount -= 1
                if repeatCount == 0 { $0.invalidate() }
            }
        }
    }
    
    private var first:First
    private var second:Second
    
    init(@ViewBuilder _ first: () -> First, @ViewBuilder second: () -> Second) {
        self.first = first()
        self.second = second()
    }
}

#Preview {
    Flip2Views { Circle() } second: { Rectangle() }
}

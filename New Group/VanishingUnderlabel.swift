//
//  VanishingUnderlabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.11.2023.
//

import SwiftUI
import MyPackage

struct VanishingUnderlabel<Top:View, Bottom:View>: View {
    
    @State private var isBottomVisible = true
    private let delay:DispatchTime = .now() + 2.5
    
    var body: some View {
        VStack {
            top
            if let bottom = bottom, isBottomVisible { bottom }
        }
        .onAppear {
            guard bottom != nil else { return }
            
            delayExecution(delay) {
                withAnimation(.spring(response: 3.0, dampingFraction: 0.4)) {
                    isBottomVisible = false
                }
            }
        }
    }
    
    private var top:Top
    private var bottom:Bottom?
    
    init(@ViewBuilder _ top: () -> Top, @ViewBuilder bottom: () -> Bottom?) {
        self.top = top()
        self.bottom = bottom()
    }
}

#Preview {
    VanishingUnderlabel {
        Image.stopwatch
            .font(.largeTitle)
    } bottom: {
        Text("Stopw")
            .font(.system(size: 14))
    }
}

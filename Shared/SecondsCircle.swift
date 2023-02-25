//
//  SecondsCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
//

import SwiftUI
import MyPackage

struct SecondsCircle: View {
    @EnvironmentObject private var viewModel:ViewModel
    let bubble:Bubble
    let color:Color
    let scale:CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .rotationEffect(.degrees(45))
                .gesture(tap)
                .gesture(longPress)
                
            HundredthsCircle(bubble: bubble)
        }
        .scaleEffect(x: scale, y: scale)
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
    
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3).onEnded { _ in endSession() }
    }
    
    // MARK: -
    private func userTappedSeconds() {
        //feedback
        UserFeedback.singleHaptic(.heavy)
        
        //user intent model
        viewModel.toggleStart(bubble)
    }
    
    private func endSession() {
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        viewModel.endSession(bubble)
    }
}

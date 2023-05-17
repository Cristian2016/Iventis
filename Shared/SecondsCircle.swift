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
    @ObservedObject var bubble:Bubble
    let color:Color
    let scale:CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .rotationEffect(.degrees(45))
                .gesture(tap)
                .gesture(longPress)
                
            HundredthsLabel(bubble: bubble)
        }
        .scaleEffect(x: scale, y: scale)
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
    
    private var longPress: some Gesture {
        LongPressGesture().onEnded { _ in endSession() }
    }
    
    // MARK: -
    private func userTappedSeconds() {
        //user intent model
        viewModel.startPause(bubble)
    }
    
    private func endSession() {
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        viewModel.endSession(bubble)
    }
}

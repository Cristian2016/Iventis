//
//  SecondsLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//

import SwiftUI

struct SecondsLabel: View {
    let bubble:Bubble
    @Environment(ViewModel.self) var viewModel
            
    var body: some View {
        ZStack {
            clearCircle
                .overlay (secondsLabel)
                .overlay (timerProgressView)
        }
    }
    
    // MARK: - Lego
    private var secondsLabel:some View {
        clearRectangle
            .aspectRatio(1.2, contentMode: .fit)
            .overlay (text)
    }
    
    private var timerProgressView:some View {
        VStack {
            Color.clear
                .aspectRatio(5.8, contentMode: .fit)
                .overlay { TimerProgressView(bubble: bubble) }
            Color.clear
            Color.clear
        }
        .scaleEffect(x: 1.4, y: 1.4)
    }
     
    private var clearCircle: some View {
        Circle().fill(Color.clear)
    }
    
    private var clearRectangle:some View {
        Rectangle().fill(.clear)
    }
    
    private var text:some View {
        let sec = bubble.coordinator.timeComponents.sec
        
        return Text(sec).allowsHitTesting(false)
            .font(.system(size: 400))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
    }
    
    // MARK: - Init
    init?(bubble: Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
    }
}

extension SecondsLabel {
    struct TimerProgressView:View {
        var bubble:Bubble
        
        var body: some View {
            ZStack {
                if bubble.coordinator.isTimer {
                    Text(bubble.coordinator.timerProgress)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.1)
                        .padding([.leading, .trailing], 4)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
                        .environment(\.colorScheme, .light)
                }
            }
        }
    }
}

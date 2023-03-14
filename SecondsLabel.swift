//
//  SecondsLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//

import SwiftUI

struct SecondsLabel: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
        
    @State private var sec:String
    
    var body: some View {
        if bubble.coordinator != nil {
            Circle().fill(Color.clear)
                .overlay {
                    Rectangle().fill(.clear)
                        .aspectRatio(1.2, contentMode: .fit)
                        .overlay (text)
                        .overlay (DeleteConfirmationLabel())
                }
                .onReceive(bubble.coordinator.$components) { sec = $0.sec }
        }
    }
    
    // MARK: - Lego
    private var text:some View {
        Text(sec).allowsHitTesting(false)
            .font(.system(size: 400))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
    }
    
    // MARK: - Init
    init?(bubble: Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
        self.sec = bubble.coordinator.components.sec
    }
}

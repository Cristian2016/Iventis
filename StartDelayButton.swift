//
//  StartDelayButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//

import SwiftUI

struct StartDelayButton: View {
    @EnvironmentObject private var viewModel:ViewModel
    @StateObject private var bubble:Bubble
    
    var body: some View {
        ZStack {
            if $bubble.startDelay.wrappedValue != 0 {
                Circle()
            }
        }
    }
    
    init?(bubble: Bubble?) {
        guard let bubble = bubble else { return nil }
        
        _bubble = StateObject(wrappedValue: bubble)
    }
}

struct StartDelayButton_Previews: PreviewProvider {
    static var previews: some View {
        StartDelayButton(bubble: nil)
    }
}

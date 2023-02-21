//
//  ScrollToTopButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.02.2023.
//

import SwiftUI

struct ScrollToTopButton: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                Button { Secretary.shared.scrollToTop() } label: { Image.scrollToTop }
                    .transition(scale)
            }
        }
        .onReceive(Secretary.shared.$showScrollToTopButton) { output in
            withAnimation { show = output }
        }
    }
    
    // MARK: -
    let scale = AnyTransition.asymmetric(insertion: .scale, removal: .slide)
}


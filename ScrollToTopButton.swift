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
                    .transition(.scale.combined(with: .move(edge: .leading)))
            }
        }
        .onReceive(Secretary.shared.$showScrollToTopButton) { output in
            withAnimation { show = output }
        }
    }
}


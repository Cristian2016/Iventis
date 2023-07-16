//
//  ScrollToTopButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.02.2023.
//

import SwiftUI

struct ScrollToTopButton: View {
    @State private var show = false
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if show {
                Button { secretary.scrollToTop() } label: {
                    Image.scrollToTop
                        .background(.white.opacity(.Opacity.basicallyTransparent))
                }
                .transition(.scale)
                .tint(.infoColor)
            }
        }
        .onChange(of: secretary.showScrollToTopButton) {_, output in
            withAnimation { show = output }
        }
    }
}


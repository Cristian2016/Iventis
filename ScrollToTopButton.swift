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
        Button { Secretary.shared.scrollToTop() } label: { Image.scrollToTop }
        .opacity(show ? 1 : 0)
        .onReceive(Secretary.shared.$showScrollToTopButton) { output in
            withAnimation { show = output }
        }
    }
}

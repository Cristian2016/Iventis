//
//  MoreOptionsGreenArea.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.03.2023.
//

import SwiftUI

struct MoreOptionsGreenArea: View {
    @State private var showMoreOptionsHint = false
    
    var body: some View {
        ZStack {
            if showMoreOptionsHint {
                Color
                    .green
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            Secretary.shared.showMoreOptionsHint = false
                        }
                    }
            }
        }
        .onReceive(Secretary.shared.$showMoreOptionsHint) { output in
            withAnimation { showMoreOptionsHint = output }
        }
    }
}

struct MoreOptionsMaskArea: View {
    @State private var showMoreOptionsHint = false
    
    var body: some View {
        ZStack {
            if showMoreOptionsHint {
                Color
                    .white
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            Secretary.shared.showMoreOptionsHint = false
                        }
                    }
            }
        }
        .onReceive(Secretary.shared.$showMoreOptionsHint) { output in
            withAnimation { showMoreOptionsHint = output }
        }
    }
}

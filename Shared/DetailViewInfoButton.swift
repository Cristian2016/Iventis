//
//  DetailViewInfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.02.2023.
//

import SwiftUI
import MyPackage

struct DetailViewInfoButton: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                Button {
                    if !Secretary.shared.showDetailViewInfo {
                        Secretary.shared.showDetailViewInfo = true
                    }
                } label: {
                    Image.info
                }
            }
        }
        .onReceive(Secretary.shared.$showDetailViewInfoButton) { output in
            withAnimation { show = output }
        }
        .tint(.yellow)
    }
}

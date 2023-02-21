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
        Button {
            if !Secretary.shared.showDetailViewInfo {
                Secretary.shared.showDetailViewInfo = true
            }
        } label: {
            Image.info
        }
        .opacity(show ? 1 : 0)
        .onReceive(Secretary.shared.$showDetailViewInfoButton) { output in
            withAnimation { show = output }
        }
        .tint(.yellow)
    }
}

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
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if show {
                Button {
                    if !secretary.showDetailViewInfo { secretary.showDetailViewInfo = true }
                } label: {
                    Image.info
                }
                .tint(.infoColor)
                .transition(.scale)
            }
        }
        .onChange(of: secretary.showDetailViewInfoButton) {_, output in
            withAnimation { show = output }
        }
    }
}

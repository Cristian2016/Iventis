//
//  OverlayScroll.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 09.12.2023.
// 1 on iPad if the width is too thin, it should have padding

import SwiftUI

struct OverlayScrollView<Content:View>: View {
    var body: some View {
        ScrollView {
            content
                .padding(Device.isIPad ? 2 : 0) //1
                .containerRelativeFrame(.vertical)
                .gesture(emptyTap)
        }
        .onTapGesture { action() }
        .frame(maxHeight: .Overlay.scrollViewHeight)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .refreshable { action() }
    }
        
    init(@ViewBuilder _ content: () -> Content, action: @escaping () -> ()) {
        self.action = action
        self.content = content()
    }
    
    private var content:Content
    private var action:() -> ()
    
    private var emptyTap:some Gesture { TapGesture() }
}

#Preview {
    OverlayScrollView { } action: { }
}

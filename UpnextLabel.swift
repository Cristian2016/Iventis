//
//  UpnextLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.05.2023.
//

import SwiftUI

struct UpnextLabel: View {
    
    let metrics = Metrics()
    @State private var showAll = true
        
    var body: some View {
        HStack {
            Label("Up Next", systemImage: "arrowtriangle.right.fill")
                .foregroundColor(.white)
                .font(metrics.upnextFont)
                .padding(metrics.upnextPadding)
                .background { innerRect }
            Label("Timer", systemImage: "timer").font(metrics.titleFont)
        }
        .onTapGesture { showAll = !showAll }
        .padding(metrics.titlePadding)
        .background { outerRect }
    }
    
    private var innerRect:some View {
        RoundedRectangle(cornerRadius: metrics.upnextRadius)
            .fill(.secondary)
    }
    
    private var outerRect:some View {
        RoundedRectangle(cornerRadius: metrics.outerRadius).fill(.quaternary)
    }
}

extension UpnextLabel {
    struct Metrics {
        let upnextFont = Font.system(size: 16).weight(.medium)
        let titleFont = Font.system(size: 18).weight(.medium)
        let upnextPadding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        let titlePadding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        let outerRadius = CGFloat(30)
        let upnextRadius = CGFloat(8)
    }
}

struct UpnextLabel_Previews: PreviewProvider {
    static var previews: some View {
        UpnextLabel()
    }
}

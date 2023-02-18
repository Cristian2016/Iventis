//
//  SecondsCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
//

import SwiftUI

struct SecondsCircle: View {
    let color:Color
    let scale:CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                
            Circle()
                .fill(Color.pauseStickerColor)
                .scaleEffect(x: 0.35, y: 0.35, anchor: .bottomTrailing)
        }
        .scaleEffect(x: scale, y: scale)
    }
}

//
//  SecondsCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.02.2023.
//

import SwiftUI

struct SecondsCircle: View {
    let bubble:Bubble
    let color:Color
    let scale:CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                
            HundredthsCircle(bubble: bubble)
        }
        .scaleEffect(x: scale, y: scale)
    }
}

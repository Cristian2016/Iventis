//
//  tBubbleCell.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 09.02.2023.
//

import SwiftUI

struct tBubbleCell: View {
    private let secretary = Secretary.shared
    
    @ObservedObject var bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    init(_ bubble: Bubble, _ metrics: Metrics) {
        self.bubble = bubble
    }
    
    var body: some View {
        let _ = print("tBubble body")
        ZStack {
            ThreeCircles(bubble)
            ThreeLabels(bubble: bubble)
        }
        .onTapGesture {
            bubble.color = Color.triColors.randomElement()!.description
            PersistenceController.shared.save()
        }
        .onAppear { bubble.coordinator.wakeUp() }
    }
}



extension tBubbleCell {
    ///circle diameter, font size, spacing and so on
    struct Metrics {
        static var width:CGFloat = 0
        
        init(_ width:CGFloat) {
            self.spacing = width * -0.18
            self.timeComponentsFontSize = width * CGFloat(0.16)
            self.hundredthsFontSize = width * CGFloat(0.06)
            Metrics.width = width
        }
        
        let spacing:CGFloat
        let timeComponentsFontSize:CGFloat
        let hundredthsFontSize:CGFloat
        let cellPadding = EdgeInsets(top: 0, leading: -12, bottom: 0, trailing: -12)
    }
}

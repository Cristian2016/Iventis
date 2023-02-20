//
//  PairRunningCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.05.2022.
//

import SwiftUI
import MyPackage

///it's the small bubble cell in the PairCell of BottomDetaiulView that only shows up when bubble is running and detailMode is active
struct PairBubbleCell: View {
            
    let bubble:Bubble
    let metrics:BubbleCell.Metrics
    
    var body: some View {
        ZStack {
            background
           
        }
    }
    
    let edge = CGFloat(130)
    let ratio = CGFloat(8.25/3)
    
    // MARK: - LEGOS
    var background: some View {
        ZStack {
            Rectangle().fill(.clear)
                .aspectRatio(metrics.ratio, contentMode: .fit)
                .overlay {
                    HStack {
                        whiteCircle
                        whiteCircle
                        whiteCircle
                    }
                    .scaleEffect(x: metrics.hstackScale, y: metrics.hstackScale)
                }
            PairBubbleCell.ThreeLabels(metrics.timeComponentsFontSize, bubble)
        }
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.label)
                .padding(-14)
                .padding([.leading, .trailing], -4)
        }
    }
    
    // MARK: - Lego
    private var whiteCircle:some View {
        Circle()
            .fill(.white)
            .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
    }
}

extension PairBubbleCell {
    struct ThreeLabels : View {
        var bubble:Bubble?
        let timeComponentsFontSize:CGFloat
        let metrics = BubbleCell.Metrics()
        
        @State private var hr:String
        @State private var min:String
        @State private var sec:String
        
        var body: some View {
            Rectangle().fill(.clear)
                .aspectRatio(metrics.ratio, contentMode: .fit)
                .overlay {
                    HStack {
                        clearCircle
                            .overlay {
                                Rectangle().fill(.green)
                                    .aspectRatio(1.2, contentMode: .fit)
                                    .overlay {
                                        Text(hr).allowsHitTesting(false)
                                            .font(.system(size: 400))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                            }
                        clearCircle
                            .overlay {
                                Rectangle().fill(.clear)
                                    .aspectRatio(1.2, contentMode: .fit)
                                    .overlay {
                                        Text(min).allowsHitTesting(false)
                                            .font(.system(size: 400))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                            }
                        clearCircle
                            .overlay {
                                Rectangle().fill(.green)
                                    .aspectRatio(1.2, contentMode: .fit)
                                    .overlay {
                                        Text(sec).allowsHitTesting(false)
                                            .font(.system(size: 400))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                            }
                    }
                    .scaleEffect(x: metrics.hstackScale, y: metrics.hstackScale)
                }
        }
        
        // MARK: - Lego
        private var clearCircle:some View {
            Circle()
                .fill(.clear)
                .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
        }
        
        // MARK: -
        init?(_ timeComponentsFontSize:CGFloat,
             _ bubble:Bubble?) {
            
            guard let bubble = bubble else { return nil }
            
            self.timeComponentsFontSize = timeComponentsFontSize
            self.bubble = bubble
                    
            if bubble.color == nil { return nil }
            
            let components = bubble.coordinator.components
            hr = components.hr
            min = components.min
            sec = components.sec
        }
    }
}

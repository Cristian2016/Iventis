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
            
    @StateObject var bubble:Bubble
    let metrics:BubbleCell.Metrics
    
    var body: some View {
        ZStack {
            background
            timeComponents
                .foregroundColor(Color("smallBubbleCircleColor"))
        }
    }
    
    let edge = CGFloat(130)
    let ratio = CGFloat(8.25/3)
    
    // MARK: - LEGOS
    var background: some View {
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
            .background {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.label)
            }
    }
    
    private var whiteCircle:some View {
        Circle()
            .fill(.white)
            .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
    }
    
    var timeComponents: some View {
        HStack (spacing: -40) {
            //HOURS
            Circle().fill(Color.clear)
                .overlay { Text(bubble.smallBubbleView_Components.hr) }
            
            //MINUTES
            Circle().fill(Color.clear)
                .overlay { Text(bubble.smallBubbleView_Components.min) }
            
            //SECONDS
            ZStack {
                Circle().fill(Color.clear)
                    .overlay { Text(bubble.smallBubbleView_Components.sec) }
            }
        }
        .font(.system(size: metrics.timeComponentsFontSize))
        .fontDesign(.rounded)
        .foregroundColor(.black)
    }
}

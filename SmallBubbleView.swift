//
//  PairRunningCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.05.2022.
//

import SwiftUI

///it's the small bubble cell in the PairCell of BottomDetaiulView that only shows up when bubble is running and detailMode is active
struct SmallBubbleView: View {
    
    @StateObject var bubble:Bubble
    static var metrics = Metrics()
    
    let edge = CGFloat(130)
    let ratio = CGFloat(8.25/3)
    
    // MARK: - LEGOS
    var background: some View {
        HStack (spacing: BubbleCell.metrics.spacing) {
            //Hours
            Circle().opacity(hrOpacity)
            //Minutes
            Circle().opacity(minOpacity)
            //Seconds
            Circle()
        }
    }
    
    var timeComponents: some View {
        HStack (spacing: SmallBubbleView.metrics.spacing) {
            //HOURS
            Circle().fill(Color.clear)
                .overlay { Text(bubble.smallBubbleView_Components.hr) }
                .opacity(hrOpacity)
            
            //MINUTES
            Circle().fill(Color.clear)
                .overlay { Text(bubble.smallBubbleView_Components.min) }
                .opacity(minOpacity)
            
            //SECONDS
            ZStack {
                Circle().fill(Color.clear)
                    .overlay { Text(bubble.smallBubbleView_Components.sec) }
            }
        }
        .font(.system(size: BubbleCell.metrics.fontSize))
        .foregroundColor(.background)
    }
    
    //stopwatch: minutes and hours stay hidden initially
    private var minOpacity:Double {
        bubble.smallBubbleView_Components.min > "0" || bubble.smallBubbleView_Components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.smallBubbleView_Components.hr > "0" ? 1 : 0.001 }
    
    var body: some View {
        ZStack {
            background
            timeComponents
        }
        .frame(width: edge * ratio)
        .foregroundColor(Color("smallBubbleCircleColor"))
    }
    
    struct TimeComponents:ViewModifier {
        let edge:CGFloat
        
        func body(content: Content) -> some View {
            content
                .frame(width: edge, height: edge)
                .foregroundColor(.background) //text color
                .font(.system(size: 45).weight(.medium))
        }
    }
}

extension SmallBubbleView {
    struct Metrics {
        var circleDiameter:CGFloat = {
            if UIDevice.isIPad {
                return 140
            } else {
               return CGFloat(UIScreen.main.bounds.size.width / 2.7)
            }
        }()
        let fontRatio = CGFloat(0.42)
        let spacingRatio = CGFloat(-0.28)
        
        lazy var spacing = circleDiameter * spacingRatio
        lazy var fontSize = circleDiameter * fontRatio
        lazy var hundredthsFontSize = circleDiameter / 6
        
//        lazy var hundredthsInsets = EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 10)
        lazy var hundredthsInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

//struct PairRunningCell_Previews: PreviewProvider {
//    static var previews: some View {
//        SmallBubbleCell(bubble: <#Bubble#>)
//    }
//}

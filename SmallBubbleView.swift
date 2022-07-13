//
//  PairRunningCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.05.2022.
//

import SwiftUI

///it's the small bubble cell in the PairCell of BottomDetaiulView that only shows up when bubble is running and detailMode is active
struct SmallBubbleView: View {
    enum Appearance { //4 cases
        case bigBlackBackground //default
        case bigWhiteBackground
        case medium
        case small
    }
    
    ///user taps and cycles through various looks
    var appearance: Appearance {
        get {
            switch skinTapsCount%3 {
                case 0: return .bigBlackBackground
                case 1: return .bigWhiteBackground
                case 2: return .medium
                case 3: return .small
                default: return .small
            }
        }
        
        set {
            switch newValue {
                case .bigBlackBackground : skinTapsCount = 0
                case .bigWhiteBackground : skinTapsCount = 1
                case .medium : skinTapsCount = 2
                case .small : skinTapsCount = 3
            }
        }
    }
    
    ///user taps and chooses various skins
    @AppStorage("skinTapsCount") var skinTapsCount: Int = 0
    @AppStorage("zoom") var isZoomed: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
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
        .compositingGroup()
        .foregroundColor(.white)
        .standardShadow()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(fillColor)
                .padding(-10)
        }
    }
    
    var fillColor: Color {
        let isLight = colorScheme == .light
        
        switch appearance {
            case .bigBlackBackground:
                return isLight ? .black : .clear
            default:
                return .clear
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
        .font(
            .system(size: isZoomed ? BubbleCell.metrics.fontSize : 42)
            .weight(isZoomed ? .regular : .medium)
        )
        .foregroundColor(.black)
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
        .frame(height: isZoomed ? 140 : 110)
        .foregroundColor(Color("smallBubbleCircleColor"))
        .onTapGesture { withAnimation {
            isZoomed.toggle()
            skinTapsCount += 1
        } }
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

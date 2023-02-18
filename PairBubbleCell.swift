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
    enum Appearance { //4 cases
        case bigBlackBackground //default
        case bigWhiteBackground
    }
    
    ///user taps and cycles through various looks
    var appearance: Appearance {
        get {
            switch skinTapsCount%2 {
                case 0: return .bigBlackBackground
                case 1: return .bigWhiteBackground
                default: return .bigBlackBackground
            }
        }
        
        set {
            switch newValue {
                case .bigBlackBackground : skinTapsCount = 0
                case .bigWhiteBackground : skinTapsCount = 1
            }
        }
    }
    
    ///user taps and chooses various skins
    @AppStorage("skinTapsCount") var skinTapsCount: Int = 0
    @AppStorage("zoom") var isZoomed: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var bubble:Bubble
    let metrics:BubbleCell.Metrics
    
    var body: some View {
        ZStack {
            background
            timeComponents
                .foregroundColor(Color("smallBubbleCircleColor"))
                .onTapGesture { withAnimation {
                    isZoomed.toggle()
                    skinTapsCount += 1
                } }
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.size.width) { newValue in
                        print("width is \(newValue)")
                    }
            }
        }
    }
    
    let edge = CGFloat(130)
    let ratio = CGFloat(8.25/3)
    
    // MARK: - LEGOS
    var background: some View {
        HStack (spacing: -40) {
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
        HStack (spacing: -40) {
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
        .font(.system(size: metrics.timeComponentsFontSize))
        .fontDesign(.rounded)
        .foregroundColor(.black)
    }
    
    //stopwatch: minutes and hours stay hidden initially
    private var minOpacity:Double {
        bubble.smallBubbleView_Components.min > "0" || bubble.smallBubbleView_Components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.smallBubbleView_Components.hr > "0" ? 1 : 0.001 }
}

//struct PairRunningCell_Previews: PreviewProvider {
//    static var previews: some View {
//        SmallBubbleCell(bubble: <#Bubble#>)
//    }
//}

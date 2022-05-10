//
//  PairRunningCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.05.2022.
//

import SwiftUI

///it's the small bubble cell in the PairCell of BottomDetaiulView that only shows up when bubble is running and detailMode is active
struct SmallBubbleCell: View {
    
    @StateObject var bubble:Bubble
    
    let edge = CGFloat(110)
    let ratio = CGFloat(8.25/3)
    
    var body: some View {
        ZStack {
            //background
            ZStack {
                HStack {
                    Spacer()
                    Circle()
                        .frame(width: edge, height: edge)
                }
                HStack {
                    Spacer()
                    Circle()
                        .frame(width: edge, height: edge)
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: edge, height: edge)
                    Spacer()
                }
            }
            .compositingGroup()
            .standardShadow(false)
        
            //time components
            //hours
            HStack {
                Text(bubble.smallBubbleCellComponents.hr)
                    .modifier(TimeComponents(edge: edge))
                Spacer()
            }
            //minutes
            HStack {
                Spacer()
                Text(bubble.smallBubbleCellComponents.min)
                    .modifier(TimeComponents(edge: edge))
                Spacer()
            }
            
            //seconds
            HStack {
                Spacer()
                Text(bubble.smallBubbleCellComponents.sec)
                    .modifier(TimeComponents(edge: edge))
            }
        }
        .frame(width: edge * ratio)
        .foregroundColor(Color("smallBubbleCircleColor"))
    }
    
    struct TimeComponents:ViewModifier {
        let edge:CGFloat
        
        func body(content: Content) -> some View {
            content
                .frame(width: edge, height: edge)
                .foregroundColor(.black) //text color
                .font(.system(size: 40).weight(.medium))
        }
    }
}

//struct PairRunningCell_Previews: PreviewProvider {
//    static var previews: some View {
//        SmallBubbleCell(bubble: <#Bubble#>)
//    }
//}

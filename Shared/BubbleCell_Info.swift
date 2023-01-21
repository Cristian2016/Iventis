//
//  BubbleCell_Info.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.07.2022.
//

import SwiftUI

struct BubbleCell_Info: View {
    var body: some View {
        ZStack {
            background
            timeComponents
        }
//        .overlay { calendarView }
        .padding()
    }
    
    // MARK: - Legoes
    ////added to bubbleCell only if cellLow value is needed. ex: to know how to position DeleteActionView
    private var cellLowEmitterView: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 10, height: 10)
    }
    
    private var hundredthsView:some View {
        Text("00")
            .background(Circle()
                .foregroundColor(Color("pauseStickerColor"))
                .padding(-12))
            .foregroundColor(Color("pauseStickerFontColor"))
            .font(.system(size: BubbleCell.metrics.hundredthsFontSize, weight: .semibold, design: .default))
        //animations:scale, offset and opacity
            .frame(width: 50, height: 50)
            .zIndex(1)
    }
    
    private var calendarView:some View {
        VStack {
            HStack {
                CalendarSticker().offset(x: -10, y: -10)
                Spacer()
            }
            Spacer()
        }
    }
    
    private var bubbleNote:some View { Push(.topLeft) { BubbleNote() } }
    
    var timeComponents: some View {
        HStack (spacing: BubbleCell.metrics.spacing) {
            Circle().fill(Color.black)
            Circle().fill(Color.black)
            ZStack { Circle().fill(Color.black.gradient) }
                .overlay { Push(.bottomRight) { hundredthsView } }
        }
        .font(.system(size: BubbleCell.metrics.fontSize))
        .foregroundColor(.white)
    }
    
    var background: some View {
        HStack (spacing: BubbleCell.metrics.spacing) {
            Circle().fill(Color.clear)
            Circle().fill(Color.clear)
            Circle()
        }
    }
}

struct BubbleCell_Info_Previews: PreviewProvider {
    static var previews: some View {
        BubbleCell_Info()
    }
}

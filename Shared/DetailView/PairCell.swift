//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    @StateObject var pair:Pair
    let duration:Float.TimeComponentsAsStrings?
    let pairNumber:Int
    
    // MARK: - Little Things
    let contentFrameGap = CGFloat(4) //how much gap between content and its enclosing frame
    let durationFont = Font.system(size: 22, weight: .medium, design: .default)
    let durationComponentsFont = Font.system(size: 19, weight: .medium, design: .default)
    
    var body: some View {
        if !pair.isFault {
            VStack (alignment: .leading) {
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.label)
                        .frame(width: 30, height: 2)
                        .overlay {
                            Text("\(pairNumber)")
                                .foregroundColor(.label)
                                .font(.system(size: 18).weight(.medium))
                                .padding(.leading, 6)
                                .offset(y: 14)
                        }
                        .offset(x: 14, y: -4)
                }
                
                //start time and date
                HStack {
                    Text(DateFormatter.bubbleStyleTime.string(from: pair.start ?? Date()))
                        .font(.monospaced(Font.system(size: 22))())
                    Text(DateFormatter.bubbleStyleDate.string(from: pair.start ?? Date()))
                        .foregroundColor(.secondary)
                }
                //pause time and date
                if let pause = pair.pause {
                    let startAndPauseOnSameDay = DateFormatter.bubbleStyleShortDate.string(from: pair.start!) == DateFormatter.bubbleStyleShortDate.string(from: pause)
                    
                        HStack {
                            Text(DateFormatter.bubbleStyleTime.string(from: pause))
                                .font(.monospaced(Font.system(size: 22))())
                            if !startAndPauseOnSameDay {
                                Text(DateFormatter.bubbleStyleDate.string(from: pause))
                                    .foregroundColor(.secondary)
                            }
                        }
                }
                
                if pair.pause == nil { SmallBubbleView(bubble: pair.session!.bubble!) }
                else { durationView }
            }
            .padding(contentFrameGap)
        }
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            if let duration = duration {
                //hr
                if duration.hr != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.hr).font(durationFont)
                        Text("h").font(durationComponentsFont)
                    }
                }
                
                //min
                if duration.min != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.min).font(durationFont)
                        Text("m").font(durationComponentsFont)
                    }
                }
                
                //sec
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec + "." + duration.cents).font(durationFont)
                    Text("s").font(durationComponentsFont)
                }
            }
        }
    }
    
    init(_ pair:Pair, _ pairNumber:Int) {
        _pair = StateObject(wrappedValue: pair)
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: pair.durationAsStrings ?? Data())
        self.duration = result
        self.pairNumber = pairNumber
    }
}

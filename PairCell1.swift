//
//  PairCell1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.01.2023.
//1 ex: if it's not @StateObject it will not update stickyNote content
// pair is actually the wrapped value. _pair is the StateObject struct
// @StateObject var pair:Pair means struct StateObject has a wrapped value of type Pair

import SwiftUI
import MyPackage

struct PairCell1: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var pair:Pair //1
    let pairNumber:Int
    let duration:Float.TimeComponentsAsStrings?
    
    var body:some View {
        if !pair.isFault {
                ZStack(alignment: .leading) {
                    Push(.topRight) { separatorLine.overlay { pairNumberView }}
                    
                    VStack (alignment: .leading) {
                        pairStartView  //first line
                        pairPauseView //second line
                        if pair.pause == nil {
                            HStack {
                                Spacer()
                                SmallBubbleView(bubble: pair.session!.bubble!, metrics: BubbleCell.Metrics(150))
                                Spacer()
                            }
                        }
                        else { durationView } //third line
                    }
                }
            }
    }
    
    // MARK: - Little Things
    
    private let metrics = Metrics()
    
    struct Metrics {
        //these two combined
        let durationFont = Font.system(size: 22, weight: .medium) //15 59 3
        let durationComponentsFont = Font.system(size: 22, weight: .medium) //h m s
    }
    
    // MARK: - Lego
    private var separatorLine:some View {
        Rectangle()
            .fill(Color.label)
            .frame(width: 30, height: 2)
            .offset(y: -4)
    }
    
    private var pairNumberView:some View {
        Text(String(pairNumber))
            .font(.system(size: 20))
            .offset(x: 4, y: 10)
    }
    
    //start time and date
    private var pairStartView: some View {
        HStack(alignment: .firstTextBaseline) {
            //time
            Text(DateFormatter.time.string(from: pair.start ?? Date()))
                .font(.monospaced(.system(size: 22))())
            //date
            Text(DateFormatter.date.string(from: pair.start ?? Date()))
                .foregroundColor(.secondary)
        }
    }
    
    //pause time and date
    @ViewBuilder
    private var pairPauseView: some View {
        if let pause = pair.pause {
            let startAndPauseOnSameDay = DateFormatter.shortDate.string(from: pair.start!) == DateFormatter.shortDate.string(from: pause)
            
                HStack(alignment: .firstTextBaseline) {
                    Text(DateFormatter.time.string(from: pause))
                        .font(.monospaced(.system(size: 22))())
                    if !startAndPauseOnSameDay {
                        Text(DateFormatter.date.string(from: pause))
                            .foregroundColor(.secondary)
                    }
                }
        }
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            if let duration = duration {
                //hr
                if duration.hr != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.hr).font(metrics.durationFont)
                        Text("h").font(metrics.durationComponentsFont)
                    }
                }
                
                //min
                if duration.min != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.min).font(metrics.durationFont)
                        Text("m").font(metrics.durationComponentsFont)
                    }
                }
                
                //sec
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec + "." + duration.cents).font(metrics.durationFont)
                    Text("s").font(metrics.durationComponentsFont)
                }
            }
        }
    }
      
    // MARK: -
    init(_ pair:Pair, _ pairNumber:Int) {
        _pair = StateObject(wrappedValue: pair)
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: pair.durationAsStrings ?? Data())
        self.duration = result
        self.pairNumber = pairNumber
    }
}

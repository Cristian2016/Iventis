//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    @ObservedObject var pair:Pair
    
    init(_ pair:Pair) {
        self.pair = pair
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            
            //start time and date
            HStack {
                Text(DateFormatter.bubbleStyleTime.string(from: pair.start))
                    .font(.monospaced(Font.body)())
                Text(DateFormatter.bubbleStyleDate.string(from: pair.start))
                    .foregroundColor(.secondary)
            }
            //pause time and date
            if let pause = pair.pause {
                let sameDates:Bool = {
                    DateFormatter.bubbleStyleDate.string(from: pair.start) ==
                    DateFormatter.bubbleStyleDate.string(from: pair.pause!)
                }()
                
                HStack {
                    Text(DateFormatter.bubbleStyleTime.string(from: pause))
                        .font(.monospaced(Font.body)())
                    if !sameDates {
                        Text(DateFormatter.bubbleStyleDate.string(from: pause))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            //duration
            HStack {
                Text(PairCell.duration(of: pair))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            //hr
//            if duration.hr != "0" {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text("23").font(.title2)
                    Text("h")
                }
//            }
            
            //min
//            if duration.min != "0" {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text("46").font(.title2)
                    Text("m")
                }
//            }
            //sec
//            if showSeconds() {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text("59").font(.title2)
                    Text("s")
                }
//            }
        }
    }
    
    private static func duration(of pair:Pair) -> DetailTopView.DurationComponents {
        let value = pair.duration.timeComponents()
        return DetailTopView.DurationComponents(String(value.hr), String(value.min), String(value.sec))
    }
}

//struct PairCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PairCell()
//    }
//}

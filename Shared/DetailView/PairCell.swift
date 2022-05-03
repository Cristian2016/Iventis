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
    
    var body: some View {
            VStack (alignment: .leading) {
                let showPause = pair.session?.bubble?.state != .running
                
                //start time and date
                HStack {
                    Text(DateFormatter.bubbleStyleTime.string(from: pair.start ?? Date()))
                        .font(.monospaced(Font.body)())
                    Text(DateFormatter.bubbleStyleDate.string(from: pair.start ?? Date()))
                        .foregroundColor(.secondary)
                }
                //pause time and date
                if let pause = pair.pause {
                    let sameDates:Bool = {
                        DateFormatter.bubbleStyleDate.string(from: pair.start ?? Date()) ==
                        DateFormatter.bubbleStyleDate.string(from: pair.pause!)
                    }()
                    
                    if showPause {
                        HStack {
                            Text(DateFormatter.bubbleStyleTime.string(from: pause))
                                .font(.monospaced(Font.body)())
                            if !sameDates {
                                Text(DateFormatter.bubbleStyleDate.string(from: pause))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                durationView
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            if let duration = duration {
                //hr
                if duration.hr != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.hr).font(.title3)
                        Text("h")
                    }
                }
                
                //min
                if duration.min != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.min).font(.title3)
                        Text("m")
                    }
                }
                
                //sec
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec + "." + duration.cents).font(.title3)
                    Text("s")
                }
            }
        }
    }
    
    init(_ pair:Pair) {
        _pair = StateObject(wrappedValue: pair)
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: pair.durationAsStrings ?? Data())
        self.duration = result
    }
}

//struct PairCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PairCell()
//    }
//}

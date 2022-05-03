//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    @StateObject var pair:Pair
    let duration:Float.TimeComponentsAsStrings
    let showSeconds:Bool
    
    var body: some View {
            VStack (alignment: .leading) {
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
                    
                    HStack {
                        Text(DateFormatter.bubbleStyleTime.string(from: pause))
                            .font(.monospaced(Font.body)())
                        if !sameDates {
                            Text(DateFormatter.bubbleStyleDate.string(from: pause))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                durationView
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
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
            if showSeconds {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec).font(.title3)
                    Text("s")
                }
            }
        }
    }
    
    init(_ pair:Pair) {
        _pair = StateObject(wrappedValue: pair)
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: pair.durationAsStrings ?? Data())
        self.duration = result ?? Float.TimeComponentsAsStrings(hr: "-1", min: "-1", sec: "-1", cents: "-1")
        
        let condition = (duration.min != "0" || duration.hr != "0")
        
        if duration.sec == "0" { self.showSeconds = condition ? false : true }
        else { self.showSeconds = true }
    }
}

//struct PairCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PairCell()
//    }
//}

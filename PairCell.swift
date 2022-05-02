//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    @StateObject var pair:Pair
    
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
                
                //duration
                durationView
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
    
    private func showSeconds() -> Bool {
        let duration = duration(of: pair)
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
    
    private var durationView:some View {
       
        HStack (spacing: 8) {
            let duration = duration(of: pair)
            
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
            if showSeconds() {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec).font(.title3)
                    Text("s")
                }
            }
        }
    }
    
    private func duration(of pair:Pair) -> DetailTopView.DurationComponents {
        let value = pair.duration.timeComponents()
        return DetailTopView.DurationComponents(String(value.hr), String(value.min), String(value.sec))
    }
}

//struct PairCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PairCell()
//    }
//}

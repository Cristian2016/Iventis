//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    var body: some View {
        VStack {
            //start time and date
            HStack {
                Text("08:12:45")
                Text("Mon, 2 May. 22")
            }
            //pause time and date
            HStack {
                Text("08:12:45")
                Text("Mon, 2 May. 22")
            }
            
            //duration
            HStack {
                
            }
        }
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
}

struct PairCell_Previews: PreviewProvider {
    static var previews: some View {
        PairCell()
    }
}

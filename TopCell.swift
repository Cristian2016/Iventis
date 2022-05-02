//
//  TopCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct TopCell: View {
    @ObservedObject var session:Session

    var color:Color
    let sessionCount:Int
    let sessionRank:String
    let duration: DetailView.DurationComponents
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            .strokeBorder(color, lineWidth: 4, antialiased: true)
            .frame(width: 150, height: 120)
            HStack {
                VStack (alignment:.leading, spacing: 6) {
                    Text(DateFormatter.bubbleStyleShortDate.string(from: session.created))
                        .font(.title2)
                        .fontWeight(.medium)
                        .background(color)
                        .foregroundColor(.white)
                    HStack (spacing: 8) {
                        if duration.hr != "0" {
                            HStack (alignment:.firstTextBaseline ,spacing: 0) {
                                Text(duration.hr).font(.title2)
                                Text("h")
                            }
                        }
                        
                        if duration.min != "0" {
                            HStack (alignment:.firstTextBaseline ,spacing: 0) {
                                Text(duration.min).font(.title2)
                                Text("m")
                            }
                        }
                        
                        if duration.sec != "0" {
                            HStack (alignment:.firstTextBaseline ,spacing: 0) {
                                Text(duration.sec).font(.title2)
                                Text("s")
                            }
                        }
                    }
                }
                .offset(x: 0, y: 10)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Text(sessionRank)
                        .foregroundColor(color)
                        .font(.title2)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 12))
                }
                Spacer()
            }
            
        }
    }
    
    // MARK: -
    ///12hr 36min 23sec
    private static func duration(of session:Session) -> DetailView.DurationComponents {
        let value = session.totalDuration.timeComponents()
        return DetailView.DurationComponents(String(value.hr), String(value.min), String(value.sec))
    }
    
    init(_ session:Session , _ sessionCount:Int, _ sessionRank:String) {
        self.sessionCount = sessionCount
        self.session = session
        
        let description = session.bubble.color
        self.color = (Color.bubbleThrees.filter { $0.description == description }.first ?? Color.Bubbles.mint).sec
        self.sessionRank = sessionRank
        self.duration = TopCell.duration(of: session)
    }
}

//struct TopCell_Previews: PreviewProvider {
//    static var previews: some View {
//        TopCell(color: .red, sessionCount: <#Int#>, session: <#Binding<Session>#>)
//    }
//}

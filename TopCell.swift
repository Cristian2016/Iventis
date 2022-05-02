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
//            RoundedRectangle(cornerRadius: 10)
//                .strokeBorder(.clear, lineWidth: 0, antialiased: true)
//                .frame(width: 150, height: 120)
            
            sessionRankView
            Push(.bottomLeft) {
                VStack (alignment:.leading, spacing: 6) {
                    dateView
                    durationView
                }
                
                .padding(EdgeInsets(top: 0, leading: 13, bottom: 10, trailing: 6))
            }
            .frame(height: 150)
            .background( backgroundView )
        }
    }
    
    // MARK: - Legoes
    private var sessionRankView:some View {
        Push(.topRight) {
            Text(sessionRank)
                .foregroundColor(color)
                .font(.title2)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 12))
        }
    }
    
    private var dateView:some View {
        Text(DateFormatter.bubbleStyleShortDate.string(from: session.created))
            .font(.title2)
            .fontWeight(.medium)
            .background(color)
            .foregroundColor(.white)
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            //hr
            if duration.hr != "0" {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.hr).font(.title2)
                    Text("h")
                }
            }
            
            //min
            if duration.min != "0" {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.min).font(.title2)
                    Text("m")
                }
            }
            
            //sec
            if showSeconds() {
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec).font(.title2)
                    Text("s")
                }
            }
        }
    }
    
    private var backgroundView:some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(color, lineWidth: 4, antialiased: true)
            RoundedRectangle(cornerRadius: 10).fill(Color.clear)
        }}
    
    // MARK: -
    ///12hr 36min 23sec
    private static func duration(of session:Session) -> DetailView.DurationComponents {
        let value = session.totalDuration.timeComponents()
        return DetailView.DurationComponents(String(value.hr), String(value.min), String(value.sec))
    }
    
    private func showSeconds() -> Bool {
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
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

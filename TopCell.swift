//
//  TopCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct TopCell: View {
    @StateObject var session:Session

    var color:Color
    let sessionCount:Int
    let sessionRank:String
    let duration: DetailTopView.DurationComponents
    
    var body: some View {
        if !session.isFault {
            ZStack {
                sessionRankView
                Push(.bottomLeft) {
                    VStack (alignment:.leading, spacing: 6) {
                        dateView
                        if session.bubble?.state == .running { bubbleRunningAlert }
                        else { durationView }
                    }
                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 10, trailing: 6))
                }
                .frame(height: 150)
                .background( backgroundView )
            }
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
    
    @ViewBuilder
    private var dateView:some View {
        if let sessionCreated = session.created {
            Text(DateFormatter.bubbleStyleShortDate.string(from: sessionCreated))
                .font(.title2)
                .fontWeight(.medium)
                .background(color)
                .foregroundColor(.white)
        } else { EmptyView() }
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            if session.bubble?.state != .running {
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
            } else {
                Text(duration.min).font(.title2).foregroundColor(.clear)
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
    private static func duration(of session:Session) -> DetailTopView.DurationComponents {
        let value = session.totalDuration.timeComponents()
        return DetailTopView.DurationComponents(String(value.hr), String(value.min), String(value.sec))
    }
    
    private func showSeconds() -> Bool {
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
    
    init(_ session:Session , _ sessionCount:Int, _ sessionRank:String) {
        self.sessionCount = sessionCount
        _session = StateObject(wrappedValue: session)
        
        let description = session.bubble?.color
        self.color = (Color.bubbleThrees.filter { $0.description == description }.first ?? Color.Bubbles.mint).sec
        self.sessionRank = sessionRank
        self.duration = TopCell.duration(of: session)
    }
    
    private var bubbleRunningAlert:some View {
        Button { } label: { Label { Text("Running").fontWeight(.semibold) } icon: { } }
    .buttonStyle(.borderedProminent)
    .foregroundColor(.white)
    .tint(.green)
    .font(.caption)
    }
}

//struct TopCell_Previews: PreviewProvider {
//    static var previews: some View {
//        TopCell(color: .red, sessionCount: <#Int#>, session: <#Binding<Session>#>)
//    }
//}

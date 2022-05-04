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
    let duration: Float.TimeComponentsAsStrings?
    
    private let topCellHeight = CGFloat(130)
    private let roundedRectRadius = CGFloat(10)
    private let strokeWidth = CGFloat(4)
    private let edgeInset = EdgeInsets(top: 0, leading: 13, bottom: 10, trailing: 6)
    private let dateDurationViewsSpacing = CGFloat(6)
    
    var body: some View {
        if !session.isFault {
            ZStack {
                sessionRankView
                Push(.bottomLeft) {
                    VStack (alignment:.leading, spacing: dateDurationViewsSpacing) {
                        dateView
                        durationView
                    }
                    .padding(edgeInset)
                }
                .frame(height: topCellHeight)
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
    
    @ViewBuilder
    private var durationView:some View {
        if let duration = duration {
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
                            Text(duration.sec + "." + duration.cents).font(.title2)
                            Text("s")
                        }
                    }
            }
           
        }
    }
    
    private var backgroundView:some View {
        ZStack {
            RoundedRectangle(cornerRadius: roundedRectRadius)
                .strokeBorder(color, lineWidth: strokeWidth, antialiased: true)
            RoundedRectangle(cornerRadius: roundedRectRadius).fill(Color.clear)
        }
        //makes sure that views with clear colors can also detect gestures
        .contentShape(Rectangle())
    }
    
    // MARK: -
    private func showSeconds() -> Bool {
        guard let duration = duration else { return false }
        
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
        
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: session.totalDurationAsStrings ?? Data())
        self.duration = result
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

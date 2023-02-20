//
//  TopCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI
import MyPackage

struct TopCell: View {
    @StateObject private var session:Session
    @State private var isSelected = false
    @Environment (\.colorScheme) private var colorScheme
    
    var color:Color
    //black if bubble is red orange magenta bubblegum
    private var selectionIndicatorColor = Color.red
    let sessionCount:Int
    let sessionRank:String
    let duration: Float.TimeComponentsAsStrings?
        
    private let topCellHeight = CGFloat(130)
    private let roundedRectRadius = CGFloat(10)
    private let strokeWidth = CGFloat(4)
    private let edgeInset = EdgeInsets(top: 0, leading: 13, bottom: 10, trailing: 6)
    private let dateDurationViewsSpacing = CGFloat(6)
    private let spacingBetweenCells = CGFloat(-2)
    
    let durationFont = Font.system(size: 24, weight: .semibold)
    let durationComponentsFont = Font.system(size: 20, weight: .semibold)
    
    // MARK: -
    var body: some View {
        if !session.isFault {
            HStack {
                ZStack {
                    sessionRankView
                    Push(.bottomLeft) {
                        VStack (alignment:.leading, spacing: dateDurationViewsSpacing) {
                            dateView
                            durationView.padding(2)
                        }.padding(edgeInset)
                    }
                    .frame(height: topCellHeight)
                    .background( backgroundView )
                    if isSelected { selectionNeedle }
                }
                Color.lightGray.frame(width:1, height: 100)
            }
           
            .onReceive(NotificationCenter.default.publisher(for: .topCellTapped)) { output in
                let cellRank = output.userInfo!["topCellTapped"] as! Int
                isSelected = cellRank == Int(sessionRank)!
            }
            .onReceive(NotificationCenter.default.publisher(for: .selectedTab)) { output in
                let selectedTab = output.userInfo?["selectedTab"] as! Int
                if sessionRank == String(selectedTab) { isSelected = true }
                else { isSelected = false }
            }
        }
    }
    
    // MARK: - Legos
    private var sessionRankView: some View {
        Push(.topRight) {
            Text(sessionRank)
                .foregroundColor(.gray)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 12))
        }
    }
    
    @ViewBuilder
    private var dateView: some View {
        if let sessionCreated = session.created {
            HStack {
                //start Date
                Text(DateFormatter.shortDate.string(from: sessionCreated))
                
                //end Date if end Date is NOT on same day as start Date
                if let pause = session.pairs_.last?.pause, !pause.sameDay(with: sessionCreated) {
                    Text("-")
                    Text(DateFormatter.shortDate.string(from: pause))
                } else {
                    if let start = session.pairs_.last?.start, !start.sameDay(with: sessionCreated) {
                        Text("-")
                        Text(DateFormatter.shortDate.string(from: start))
                    }
                }
            }
            .font(.system(size: 24))
            .fontWeight(.medium)
            .background(color)
            .foregroundColor(.white)
        } else { EmptyView() }
    }
    
    @ViewBuilder
    private var durationView: some View {
        if let duration = duration {
            HStack (spacing: 8) {
                    //hr
                    if duration.hr != "0" {
                        HStack (alignment:.firstTextBaseline ,spacing: 0) {
                            Text(duration.hr).font(durationFont)
                            Text("h").font(durationComponentsFont)
                        }
                    }
                    
                    //min
                    if duration.min != "0" {
                        HStack (alignment:.firstTextBaseline ,spacing: 0) {
                            Text(duration.min).font(durationFont)
                            Text("m").font(durationComponentsFont)
                        }
                    }
                    
                    //sec
                    if showSeconds() {
                        HStack (alignment:.firstTextBaseline ,spacing: 0) {
                            Text(duration.sec + "." + duration.hundredths).font(durationFont)
                            Text("s").font(durationComponentsFont)
                        }
                    }
            }
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: roundedRectRadius).fill(Color.clear)
            .padding([.trailing, .leading], 2)
            .contentShape(Rectangle())
    }
    
    private var bubbleRunningAlert: some View {
        Button { } label: { Label { Text("Running").fontWeight(.semibold) } icon: { } }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.white)
            .tint(.green)
            .font(.caption)
    }
    
    private var selectionNeedle: some View {
        VStack {
            ZStack {
                Image(systemName: "arrowtriangle.down.fill")
                    .foregroundColor(.red)
                    .font(.footnote)
                Divider()
                    .frame(width: 40)
            }
            Spacer()
        }
//        VStack {
//            ZStack {
//                Rectangle()
//                    .fill(selectionIndicatorColor)
//                    .frame(width: 4, height: 35)
//                selectionIndicatorColor
//                    .frame(width: 20, height: 1)
//            }
//
//            Spacer()
//        }
    }
    
    // MARK: -
    private func showSeconds() -> Bool {
        guard let duration = duration else { return false }
        
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
    
    init(_ session:Session ,
         _ sessionCount:Int,
         _ sessionRank:String) {
        
        self.sessionCount = sessionCount
        _session = StateObject(wrappedValue: session)
        
        self.color = Color.bubbleColor(forName: session.bubble?.color)
        self.sessionRank = sessionRank
        
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: session.totalDurationAsStrings ?? Data())
        self.duration = result
        
        if ["magenta", "red", "bubbleGum", "orange", "sourCherry"].contains(bubbleColorDescription) {
            self.selectionIndicatorColor = .label
        }
        //⚠️ why it doesnt work
//        if Int(sessionRank)! == sessionCount {
//            self.isSelected = true
//        }
    }
}

//struct TopCell_Previews: PreviewProvider {
//    static var previews: some View {
//        TopCell(color: .red, sessionCount: <#Int#>, session: <#Binding<Session>#>)
//    }
//}

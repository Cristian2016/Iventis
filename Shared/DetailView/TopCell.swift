//
//  TopCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//1 make sure bubbleCellTimer refreshes

import SwiftUI
import MyPackage

struct TopCell: View {
    @Environment (\.colorScheme) private var colorScheme
    
    let secretary = Secretary.shared
    let session:Session
    let myRank:Int
    
    @Binding var needleRank:Int
    @State var latestSessionNeedleRank:Int!
    
    @State private var showNeedle = false
    
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
            //        let _ = print("Top Cell body")
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
                    if showNeedle { selectionNeedle }
                }
                Color.lightGray.frame(width:1, height: 100)
            }
            .onTapGesture {
                if needleRank == myRank {
                    print("fuck")
                    return
                }
                UserFeedback.singleHaptic(.medium)
                                
                delayExecution(.now() + 0.3) {
                    if pairBubbleCellShows {
                        Secretary.shared.pairBubbleCellNeedsDisplay.toggle()
                    }
                } //1
                
                withAnimation { needleRank = myRank }
            }
            .onLongPressGesture {
                UserFeedback.singleHaptic(.heavy)
                secretary.sessionToDelete = (session, myRank)
            }
            .onChange(of: needleRank) { newValue in
                showNeedle =  newValue == myRank ? true : false
            }
            .onReceive(NotificationCenter.Publisher(center: .default, name: .needleTracksLatestSession)) { notification in
                guard let needleRank = notification.userInfo?["needleRank"] as? Int else { return }
                self.latestSessionNeedleRank = needleRank
                print("latestSessionNeedleRank \(latestSessionNeedleRank ?? -1)")
            }
        }
    }
    
    // MARK: - Legos
    private var sessionRankView: some View {
        Push(.topRight) {
            Text(String(myRank))
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
            .background(DateViewBackgroundColor(session: session))
            .foregroundColor(.white)
        } else { EmptyView() }
    }
    
    @ViewBuilder
    private var durationView: some View {
        if let duration = duration, shouldDisplayDuration {
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
    }
    
    // MARK: -
    private func showSeconds() -> Bool {
        guard let duration = duration else { return false }
        
        let condition = (duration.min != "0" || duration.hr != "0")
        if duration.sec == "0" { return condition ? false : true }
        return true
    }
    
    init?(_ session:Session?, _ sessionRank:Int, _ needleRank:Binding<Int>) {
        
        guard let session = session else { return nil }
        
        self.session = session
        
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: session.totalDurationAsStrings ?? Data())
        
        // FIXME: - doing twice the work and decodes data here, instead on a background thread
        print("decode data")
        
        self.duration = result
        self.myRank = sessionRank
        _needleRank = needleRank
        _showNeedle = State(initialValue: myRank == self.needleRank ? true : false)
    }
    
    private var pairBubbleCellShows: Bool { !session.isLastPairClosed }
    
    private var shouldDisplayDuration:Bool {
        
        if myRank != session.bubble?.sessions_.count { return true }
        else {
            return pairBubbleCellShows ? false : true
        }
    }
}

struct DateViewBackgroundColor: View {
    let session:Session
    @State var color:Color
    
    init(session: Session) {
        self.session = session
        self.color = Color.bubbleColor(forName: session.bubble?.color)
    }
    
    var body: some View {
        color
            .onReceive(session.bubble?.coordinator.colorPublisher ?? .init(.clear)) {
                self.color = $0
            }
    }
}

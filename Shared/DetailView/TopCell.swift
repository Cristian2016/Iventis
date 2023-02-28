//
//  TopCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//1 make sure bubbleCellTimer refreshes

import SwiftUI
import MyPackage

struct TopCell: View {
    @Environment (\.needlePosition) private var needlePosition
    @Environment (\.colorScheme) private var colorScheme
    
    private let secretary = Secretary.shared
    private let session:Session
    private let myRank:Int
            
    @State private var duration: Float.TimeComponentsAsStrings?
    
    private let metrics = Metrics()
    
    // MARK: -
    var body: some View {
        if !session.isFault {
//            let _ = print("Topcell body")
            HStack {
                ZStack {
                    sessionRankView
                    Push(.bottomLeft) {
                        VStack (alignment:.leading, spacing: metrics.dateDurationViewsSpacing) {
                            dateView
                            TopCellDurationView(metrics, session, myRank).padding(2)
                        }
                        .padding(metrics.edgeInset)
                    }
                    .frame(height: metrics.topCellHeight)
                    .background( backgroundView )
                }
                Color.lightGray.frame(width:1, height: 100)
            }
            .onTapGesture { handleTopCellTapped() }
            .onLongPressGesture { handleTopCellLongPressed() }
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
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: metrics.roundedRectRadius).fill(Color.clear)
            .padding([.trailing, .leading], 2)
            .contentShape(Rectangle())
    }
    
    // MARK: -
    private func handleTopCellLongPressed() {
        UserFeedback.singleHaptic(.heavy)
        secretary.sessionToDelete = (session, myRank)
    }
    
    private func handleTopCellTapped() {
        if needlePosition.wrappedValue == myRank || (needleNotSet && latestTopCell) { return }
        
        //user feedback: visual and taptic
        UserFeedback.singleHaptic(.medium)
        
        delayExecution(.now() + 0.3) {
            if pairBubbleCellShows {
                Secretary.shared.pairBubbleCellNeedsDisplay.toggle()
            }
        } //1
        
        let latestSessionRank = session.bubble!.sessions_.count == myRank
        withAnimation { needlePosition.wrappedValue = latestSessionRank ? -1 : myRank }
    }
    
    private var pairBubbleCellShows: Bool { !session.isLastPairClosed }
    
    private var shouldDisplayDuration:Bool {
        
        if myRank != session.bubble?.sessions_.count { return true }
        else {
            return pairBubbleCellShows ? false : true
        }
    }
    
    // MARK: - init
    init?(_ session:Session?, _ sessionRank:Int) {
        guard let session = session else { return nil }
        self.session = session
//        _session = StateObject(wrappedValue: session)
        self.myRank = sessionRank
    }
    
    // MARK: - Little Helpers
    private var latestTopCell:Bool { myRank == session.bubble?.sessions_.count }
    
    private var needleNotSet:Bool { needlePosition.wrappedValue == -1 }
}

extension TopCell {
    struct Metrics {
        let topCellHeight = CGFloat(130)
        let roundedRectRadius = CGFloat(10)
        let strokeWidth = CGFloat(4)
        let edgeInset = EdgeInsets(top: 0, leading: 13, bottom: 10, trailing: 6)
        let dateDurationViewsSpacing = CGFloat(6)
        let spacingBetweenCells = CGFloat(-2)
        let durationFont = Font.system(size: 24, weight: .semibold)
        let durationComponentsFont = Font.system(size: 20, weight: .semibold)
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

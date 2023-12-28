//
//  TopCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//1 make sure bubbleCellTimer refreshes

import SwiftUI
import MyPackage

struct SessionCell: View {
    @Environment (\.needlePosition) private var needlePosition
    @Environment (\.colorScheme) private var colorScheme
    @Environment(Secretary.self) private var secretary
    
    private let session:Session
    private let myRank:Int
    
    @State private var duration: Float.TimeComponentsAsStrings?
    
    private let metrics = Metrics()
    
    // MARK: -
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Color.clear
                    .frame(height: 60)
                dateLabel
                TopCellDurationView(metrics, session, myRank)
            }
            .frame(minWidth: 70)
            
            Divider()
        }
        .background()
        .overlay(alignment: .topTrailing) { sessionNumberLabel }
        .onTapGesture { handleTopCellTapped() }
        .onLongPressGesture { handleTopCellLongPressed() }
    }
    
    // MARK: - Legos
    private var sessionNumberLabel: some View {
        Text(String(myRank))
            .pairCountModifier()
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 6))
    }
    
    @ViewBuilder
    private var dateLabel: some View {
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
                Spacer()
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .font(.system(size: 24))
            .foregroundStyle(.white)
            .background(Color.gray)
        }
    }
    
    // MARK: -
    private func handleTopCellLongPressed() {
        UserFeedback.singleHaptic(.heavy)
        secretary.sessionToDelete = Secretary.SessionToDelete(session: session, sessionRank: myRank)
    }
    
    private func handleTopCellTapped() {
        if needlePosition.wrappedValue == myRank || (needleNotSet && latestTopCell) { return }
        
        //user feedback: visual and taptic
        UserFeedback.singleHaptic(.medium)
        
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

extension SessionCell {
    struct Metrics {
        let durationFont = Font.system(size: 24, weight: .medium)
        let durationComponentsFont = Font.system(size: 20, weight: .medium)
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
        session.bubble?.coordinator.color
    }
}

#Preview {
    SessionCell(PersistenceController.testSession, 10)
        .environment(Secretary())
        .frame(width: 130, height: 140, alignment: .center)
}

//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//1 monitors position change, so if the user decides to put needle back in its original position, needlePosition must be reset

import SwiftUI
import MyPackage

struct BottomDetailView: View {
    @Binding var needlePosition:Int
    
    @FetchRequest var sessions:FetchedResults<Session>
    @State private var pairBubbleCellNeedsDisplay = false
    
    private let secretary = Secretary.shared
    
    init?(_ bubble:Bubble?, _ needlePosition:Binding<Int>) {
        guard let bubble = bubble else { return nil }
        
        let predicate = NSPredicate(format: "bubble.rank == %i", bubble.rank)
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        
        _sessions = FetchRequest(entity: Session.entity(),
                                 sortDescriptors: [descriptor],
                                 predicate: predicate,
                                 animation: .easeInOut)
        
        _needlePosition = needlePosition
    }
    
    var body: some View {
        TabView (selection: $needlePosition) {
            ForEach(sessions) {
                PairList($0).tag(sessionRank(of:$0))
            }
        }
        .padding(.init(top: 0, leading: -12, bottom: 0, trailing: -12))
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(secretary.$pairBubbleCellNeedsDisplay) { pairBubbleCellNeedsDisplay = $0 }
        .onChange(of: needlePosition) {
            if $0 == sessions.count { withAnimation { needlePosition = -1 }}
        } //1
    }
    
    private func sessionRank(of session:Session) -> Int {
        sessions.count - sessions.firstIndex(of: session)!
    }
}

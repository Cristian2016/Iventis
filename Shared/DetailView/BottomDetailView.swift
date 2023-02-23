//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

///it's a TabView and each tab contains a List of Paircells
struct BottomDetailView: View {
    @FetchRequest var sessions:FetchedResults<Session>
    @State private var pairBubbleCellNeedsDisplay = false
    private let bubble:Bubble
    
    private let secretary = Secretary.shared
    @State private var selectedTab = 0
    
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
        
        let predicate = NSPredicate(format: "bubble.rank == %i", bubble.rank)
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    var body: some View {
        TabView (selection: $selectedTab) {
            ForEach(sessions) {
                PairList($0)
                    .tag(sessionRank(of:$0))
            }
        }
        .padding(.init(top: 0, leading: -12, bottom: 0, trailing: -12))
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(secretary.$pairBubbleCellNeedsDisplay) { pairBubbleCellNeedsDisplay = $0 }
//        .onReceive(bubble.coordinator.$needleRank) { needleRank in
//            if !bubble.coordinator.userMovedNeedle {
//                withAnimation { self.selectedTab = needleRank ?? 0 }
//            }
//        }
        .onChange(of: selectedTab) { bubble.coordinator.needleRank = $0 }
    }
    
    private func sessionRank(of session:Session) -> Int {
        sessions.count - sessions.firstIndex(of: session)!
    }
}

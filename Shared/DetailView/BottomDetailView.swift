//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI
import MyPackage

struct BottomDetailView: View {
    @FetchRequest var sessions:FetchedResults<Session>
    @State private var pairBubbleCellNeedsDisplay = false
    private let coordinator:BubbleCellCoordinator
    @Binding var needleRank:Int
    
    private let secretary = Secretary.shared
    
    init?(_ bubble:Bubble?, _ needleRank:Binding<Int>) {
        guard let bubble = bubble else { return nil }
        
        self.coordinator = bubble.coordinator
        
        let predicate = NSPredicate(format: "bubble.rank == %i", bubble.rank)
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
        _needleRank = needleRank
    }
    
    var body: some View {
        TabView (selection: $needleRank) {
            ForEach(sessions) {
                PairList($0)
                    .tag(sessionRank(of:$0))
            }
        }
        .padding(.init(top: 0, leading: -12, bottom: 0, trailing: -12))
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(secretary.$pairBubbleCellNeedsDisplay) { pairBubbleCellNeedsDisplay = $0 }
    }
    
    private func sessionRank(of session:Session) -> Int {
        sessions.count - sessions.firstIndex(of: session)!
    }
}

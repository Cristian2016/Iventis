//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

class SelectedTabWrapper: ObservableObject {
    @Published var selectedTab = 0 {didSet {
        let info = ["selectedTab" : selectedTab]
        NotificationCenter.default.post(name: .selectedTab, object: nil, userInfo: info)
    }}
}

///it's a TabView and each tab contains a List of Paircells
struct BottomDetailView: View {
    @FetchRequest var sessions:FetchedResults<Session>
    @StateObject var tabWrapper = SelectedTabWrapper()
    @State private var pairBubbleCellNeedsDisplay = false
    private let bubble:Bubble
    
    private let secretary = Secretary.shared
    
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
        
        
        let predicate = NSPredicate(format: "bubble.rank == %i", bubble.rank)
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    var body: some View {
        TabView (selection: $tabWrapper.selectedTab) {
            ForEach(sessions) {
                PairList($0).tag(sessionRank(of:$0))
            }
        }
        .padding(.init(top: 0, leading: -12, bottom: 0, trailing: -12))
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(NotificationCenter.default.publisher(for: .topCellTapped)) {
            let row = $0.userInfo!["topCellTapped"] as! Int
            withAnimation { tabWrapper.selectedTab = row }
        }
        .onReceive(secretary.$pairBubbleCellNeedsDisplay) { output in
            pairBubbleCellNeedsDisplay = output
        }
        .onReceive(bubble.coordinator.$theOneAndOnlySelectedTopCell) { output in
            if let output = output {
                withAnimation { tabWrapper.selectedTab = Int(output)!}
            }
        }
    }
    
    private func sessionRank(of session:Session) -> Int {
        sessions.count - sessions.firstIndex(of: session)!
    }
}

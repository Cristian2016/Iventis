//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct DetailPagesView: View {
    @FetchRequest var sessions:FetchedResults<Session>
    @State private var selectedTab = 0
    
    init(_ rank:Int?) {
        let predicate:NSPredicate?
        if let rank = rank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    var body: some View {
        TabView (selection: $selectedTab) {
            ForEach(sessions) { BottomCell($0).tag(position(of:$0)) }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(NotificationCenter.default.publisher(for: .topCellTapped)) {
            let row = $0.userInfo!["topCellTapped"] as! Int
            withAnimation { selectedTab = row }
        }
    }
    
    private func position(of session:Session) -> Int {
        return sessions.count - sessions.firstIndex(of: session)!
    }
}

//struct DetailBottomView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailBottomView(session: PersistenceController.shared.viewContext.count(for: <#T##NSFetchRequest<NSFetchRequestResult>#>))
//    }
//}

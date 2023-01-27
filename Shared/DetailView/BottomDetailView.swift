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
    
    init(_ rank:Int?) {
        let predicate:NSPredicate?
        if let rank = rank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    var body: some View {
        TabView (selection: $tabWrapper.selectedTab) {
            ForEach(sessions) {
                BottomCell($0).tag(position(of:$0))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onReceive(NotificationCenter.default.publisher(for: .topCellTapped)) {
            let row = $0.userInfo!["topCellTapped"] as! Int
            withAnimation { tabWrapper.selectedTab = row }
        }
    }
    
    private func position(of session:Session) -> Int {
        sessions.count - sessions.firstIndex(of: session)!
    }
}

//struct DetailBottomView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailBottomView(session: PersistenceController.shared.viewContext.count(for: <#T##NSFetchRequest<NSFetchRequestResult>#>))
//    }
//}

//
//  DetailView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct DetailView: View {
    @StateObject var tabWrapper = SellectedTabWrapper()
    @FetchRequest var sessions:FetchedResults<Session>
    let rank:Int?
    
    init(_ rank:Int?) {
        let predicate:NSPredicate?
        if let rank = rank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
        self.rank = rank
    }
    
    var body: some View {
        VStack {
            Spacer()
            TopDetailView(rank)
                .frame(width: UIScreen.size.width * 0.96, height: 140)
            BottomDetailView(rank)
                .frame(width: UIScreen.size.width * 0.96, height: 410)
        }
        .ignoresSafeArea()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(4)
    }
}

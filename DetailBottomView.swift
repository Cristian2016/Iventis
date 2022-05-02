//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct DetailBottomView: View {
    @FetchRequest var sessions:FetchedResults<Session>
    
    init(_ rank:Int?) {
        let predicate:NSPredicate?
        if let rank = rank {
            predicate = NSPredicate(format: "bubble.rank == %i", rank)
        }
        else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {//each session cooresponding to a list
                ForEach (sessions) { session in
                    BottomCell(session: session)
                        .frame(width: UIScreen.size.width * 0.91, height: 600)
                        .offset(x: 0, y: -40)
                }
            }
        }
    }
}

//struct DetailBottomView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailBottomView(session: .constant(Session()))
//    }
//}

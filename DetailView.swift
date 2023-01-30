//
//  DetailView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI
import MyPackage

struct DetailView: View {
    let rank:Int?
    
    @StateObject var tabWrapper = SelectedTabWrapper()
    @FetchRequest var sessions:FetchedResults<Session>
    
    let topDetailHeight = CGFloat(140)
    
    init(_ showDetail_bRank:Int?) {
        let predicate:NSPredicate?
        if let rank = showDetail_bRank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
        self.rank = showDetail_bRank
    }
    
    var body: some View {
        ZStack {
            if sessions.isEmpty { EmptyHistoryAlertView() }
            else {
                VStack {
                    TopDetailView(rank).frame(height: topDetailHeight)
                    BottomDetailView(rank)
                        .frame(height: 600)
                        .background {
                            VStack {
                                Text("Scroll to Bubble")
                                    .font(.system(size: 20))
                                Text("Scroll all the way up by using the device edge")
                                Spacer()
                            }
                        }
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(4)
    }
}

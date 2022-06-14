//
//  DetailView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct DetailView: View {
    let rank:Int?
    
    @StateObject var tabWrapper = SellectedTabWrapper()
    @FetchRequest var sessions:FetchedResults<Session>
    
    let topDetailHeight = CGFloat(140)
    //empirically computed
    let bottomDetailHeight = UIScreen.size.height - (2.5 * Global.circleDiameter +  ExitFocusView.height)
    let detailWidth = UIScreen.size.width * 0.96
    
    init(_ showDetail_bRank:Int?) {
        print("DetailView init")
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
            VStack {
                Spacer()
                TopDetailView(rank)
                    .frame(width: detailWidth, height: topDetailHeight)
                BottomDetailView(rank)
                    .frame(width: detailWidth, height: bottomDetailHeight)
            }
        }
        .ignoresSafeArea()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(4)
    }
}

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
    //empirically computed
    let bottomDetailHeight = UIScreen.size.height - (2.5 * Global.circleDiameter +  ExitFocusView.height)
    let detailWidth = UIScreen.size.width * 0.96
    
    init(_ showDetail_bRank:Int?) {
        let predicate:NSPredicate?
        if let rank = showDetail_bRank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
        self.rank = showDetail_bRank
    }
    
    var body: some View {
        VStack {
            ZStack {
                if sessions.isEmpty { EmptyHistoryAlertView() }
                else {
                    VStack {
                        Spacer()
                        TopDetailView(rank)
                            .frame(height: topDetailHeight)
                            .padding(3)
                        BottomDetailView(rank)
                    }
                }
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(4)
    }
}

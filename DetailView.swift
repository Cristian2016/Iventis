//
//  DetailView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//1 visible only when scrolling vertically. If it's visible horizontally, it will show scoll indicator when scrolling in the TopDetailView, which doesn't look good
//2 scroll to top for beginners :)))

import SwiftUI
import MyPackage

struct DetailView: View {
    let rank:Int?
    let bubble:Bubble
    @StateObject var tabWrapper = SelectedTabWrapper()
    @FetchRequest var sessions:FetchedResults<Session>
    
    @EnvironmentObject private var viewModel:ViewModel
    private let secretary = Secretary.shared
        
    let topDetailHeight = CGFloat(140)
    
    init(_ showDetail_bRank:Int?, _ bubble:Bubble) {
        let _ = print("DetailView body")
        
        let predicate:NSPredicate?
        if let rank = showDetail_bRank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
        self.rank = showDetail_bRank
        self.bubble = bubble
    }
    
    var body: some View {
        ZStack {
            if sessions.isEmpty { NoSessionsAlertView() }
            else {
                TopDetailView(rank).frame(height: topDetailHeight)
                    .listRowSeparator(.hidden)
                BottomDetailView(rank)
                    .frame(height: 600)
                    .listRowSeparator(.hidden)
            }
        }
    }
    
    // MARK: - Little Helpers
    var isAddTagButtonVisible:Bool { secretary.addNoteButton_bRank == Int(bubble.rank) }
}

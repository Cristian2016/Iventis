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
    let metrics:BubbleCell.Metrics
    @StateObject var tabWrapper = SelectedTabWrapper()
    @FetchRequest var sessions:FetchedResults<Session>
    
    @EnvironmentObject private var viewModel:ViewModel
    private let secretary = Secretary.shared
    
    @State private var scrollToTop = false //2
    
    let topDetailHeight = CGFloat(140)
    
    init(_ showDetail_bRank:Int?, _ bubble:Bubble, _ metrics:BubbleCell.Metrics) {
        let _ = print("DetailView body")
        
        let predicate:NSPredicate?
        if let rank = showDetail_bRank { predicate = NSPredicate(format: "bubble.rank == %i", rank)
        } else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
        self.rank = showDetail_bRank
        self.bubble = bubble
        self.metrics = metrics
    }
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                List {
                    BubbleCell(bubble, metrics).padding(BubbleCell.padding) //2
                        .id(1)
                    if sessions.isEmpty { NoSessionsAlertView() }
                    else {
                        TopDetailView(rank).frame(height: topDetailHeight)
                            .padding(BubbleCell.padding) //2
                            .listRowSeparator(.hidden)
                        BottomDetailView(rank)
                            .frame(height: 600)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.visible, axes: .vertical) //1
                .onChange(of: scrollToTop) {
                    if $0 {
                        withAnimation { proxy.scrollTo(1) }
                        scrollToTop = false
                    }
                } //2
            }
            .toolbarBackground(.ultraThinMaterial)
            .toolbar {
                ToolbarItemGroup {
                    if isAddTagButtonVisible { AddNoteButton() }
                }
            }
        }
    }
    
    // MARK: - Little Helpers
    var isAddTagButtonVisible:Bool { secretary.addNoteButton_bRank == Int(bubble.rank) }
}

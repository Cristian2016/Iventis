//
//  DetailView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//1 visible only when scrolling vertically. If it's visible horizontally, it will show scoll indicator when scrolling in the TopDetailView, which doesn't look good

import SwiftUI
import MyPackage

struct DetailView: View {
    let rank:Int?
    let bubble:Bubble
    let metrics:BubbleCell.Metrics
    @StateObject var tabWrapper = SelectedTabWrapper()
    @FetchRequest var sessions:FetchedResults<Session>
    
    @EnvironmentObject private var viewModel:ViewModel
    
    let topDetailHeight = CGFloat(140)
    
    init(_ showDetail_bRank:Int?, _ bubble:Bubble, _ metrics:BubbleCell.Metrics) {
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
            List {
                BubbleCell(bubble, metrics).padding(BubbleCell.padding) //2
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
        }
        .toolbarBackground(.ultraThinMaterial)
        .toolbar {
            ToolbarItemGroup {
                if isAddTagButtonVisible { AddPairCellNoteButton(bubble) }
                FusedLabel(content: .init(title: "Scroll to Top", symbol: "arrow.up", size: .small))
            }
        }
    }
    
    // MARK: - Little Helpers
    var isAddTagButtonVisible:Bool { viewModel.fiveSeconds_bRank == Int(bubble.rank) }
}

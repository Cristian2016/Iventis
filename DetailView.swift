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
        ScrollViewReader { proxy in
            List {
                BubbleCell(bubble)
                    .id(1)
                    .offset(y: -6)
                    .background {
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                let offsetY = geo.frame(in: .global).origin.y

                                if offsetY < -90, !secretary.showScrollToTopButton {
                                    secretary.showScrollToTopButton = true
                                }

                                if offsetY > -90, secretary.showScrollToTopButton {
                                    secretary.showScrollToTopButton = false
                                }
                            }
                            return .clear
                        }
                    }
                if sessions.isEmpty { NoSessionsAlertView() }
                else {
                    TopDetailView(rank)
                        .frame(height: topDetailHeight)
                        .listRowSeparator(.hidden)
                    BottomDetailView(rank)
                        .frame(height: 600)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden, axes: .vertical) //1
            .onReceive(secretary.$shouldScrollToTop) {
                if $0 {
                    withAnimation { proxy.scrollTo(1) }
                    delayExecution(.now() + 0.1) { secretary.shouldScrollToTop = false }
                }
            }
        }
        .toolbarBackground(.ultraThinMaterial)
        .toolbar {
            ToolbarItemGroup {
                DetailViewInfoButton()
                ScrollToTopButton()
                if isAddTagButtonVisible { AddNoteButton() }
            }
        }
        .overlay { ShowDetailViewInfoView() }
    }
    
    // MARK: - Little Helpers
    var isAddTagButtonVisible:Bool { secretary.addNoteButton_bRank == Int(bubble.rank) }
}

struct ShowDetailViewInfoView: View {
    @State private var showDetailViewInfo = false
    
    var body: some View {
        ThinMaterialLabel(title: "Scroll To Top") {
            thinMaterialLabelContent
        } action: {
            Secretary.shared.showDetailViewInfo = false
        }
        .opacity(showDetailViewInfo ? 1 : 0)
        .onReceive(Secretary.shared.$showDetailViewInfo) { output in
            withAnimation {
                showDetailViewInfo = output
            }
        }
    }
    
    private var thinMaterialLabelContent:some View {
        VStack(alignment: .leading) {
            Text("\(Image(systemName: "digitalcrown.arrow.counterclockwise")) Scroll along any screen edge")
            Text("or \(Image.tap) Tap \(Image.scrollToTop) Symbol, if visible")
        }
    }
}

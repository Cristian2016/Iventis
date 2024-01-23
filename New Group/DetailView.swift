//
//  DetailView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//1 visible only when scrolling vertically. If it's visible horizontally, it will show scoll indicator when scrolling in the TopDetailView, which doesn't look good
//2 scroll to top for beginners :)))

import SwiftUI
import MyPackage
import CoreData

struct DetailView: View {
    @State private var needlePosition = -1
    @AppStorage(Storagekey.assistUser) private var assistUser = true
    
    @StateObject var bubble:Bubble
    @FetchRequest private var sessions:FetchedResults<Session>
    
    @Environment(ViewModel.self) var viewModel
    @Environment(Secretary.self) private var secretary
            
    var body: some View {
        if bubble.color != nil {
            ScrollViewReader { proxy in
                List {
                    BubbleCell(bubble)
                        .id(1)
                        .background { yPositionBubbleView }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    
                    if sessions.isEmpty { NoActivityAlertView() }
                    else {
                        SessionList($needlePosition, sessions)
                            .listRowSeparator(.hidden)
                            .frame(height: 150)
                        BottomDetailView($needlePosition, sessions)
                            .frame(height: 600)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden) //1
                .onChange(of: secretary.shouldScrollToTop) {
                    if $1 {
                        withAnimation { proxy.scrollTo(1) }
                        delayExecution(.now() + 0.1) { secretary.shouldScrollToTop = false }
                    }
                }
            }
            .navigationTitle(titleView)
            .toolbarBackground(.ultraThinMaterial)
            .toolbar {
                ToolbarItemGroup {
                    ZStack {
                        HStack {
                            DetailViewInfoButton()
                            ScrollToTopButton()
                        }
                        LapNoteButton()
                    }
                }
            }
            .overlay (SessionDeleteOverlay())
            .overlay (ShowDetailViewInfoView())
        }
    }
            
    private var count:Int { sessions.count }
    
    // MARK: - Lego
    private var yPositionBubbleView:some View {
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
    
    private var titleView:Text {
        let title = bubble.isTimer ? " \(bubble.initialClock.timerTitle)" : "\(String.readableName(for: bubble.color))"
        return Text(title)
    }
    
    // MARK: - Init
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        _bubble = StateObject(wrappedValue: bubble)
        
        let predicate = NSPredicate(format: "bubble.rank == %i", bubble.rank)
        let descriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        _sessions = FetchRequest(entity: Session.entity(),
                                 sortDescriptors: descriptors,
                                 predicate: predicate,
                                 animation: .default)
    }
}

struct ShowDetailViewInfoView: View {
    @Environment(Secretary.self) private var secretary
    @State private var showDetailViewInfo = false
    let title:LocalizedStringKey = "Scroll to Top"
    
    var body: some View {
        AlertOverlay(title) { infoContent } dismiss: { dismiss() }
            .opacity(showDetailViewInfo ? 1 : 0)
            .onChange(of: secretary.showDetailViewInfo) {_, output in
                withAnimation { showDetailViewInfo = output }
            }
    }
    
    private var infoContent:some View {
        Text("...along screen edges, or tap \(Image.scrollToTop)")
            .forceMultipleLines()
    }
    
    // MARK: -
    private func dismiss() { secretary.showDetailViewInfo = false }
}
//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
// References:
// how to detect scroll view stop https://stackoverflow.com/questions/65062590/swiftui-detect-when-scrollview-has-finished-scrolling

import SwiftUI
import MyPackage

struct TopDetailView:View {
    @EnvironmentObject private var viewModel:ViewModel
    @FetchRequest var sessions:FetchedResults<Session>
    @Environment(\.colorScheme) var colorScheme
    private let bubble:Bubble
    
    private let secretary = Secretary.shared
    private static var publisher = NotificationCenter.default.publisher(for: .selectedTab)
        
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        self.bubble = bubble
        let predicate = NSPredicate(format: "bubble.rank == %i", bubble.rank)
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            if colorScheme == .light { shadowBackground }
            if colorScheme == .dark { gradientBackground }
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach (sessions) {
                            let sessionRank = sessionRank(of: $0)
                            
                            TopCell($0, sessionRank).id(sessionRank)
                        }
                    }
                }
                .onReceive(bubble.coordinator.$selectedTopCellRank) { selectedRank in
                    withAnimation { proxy.scrollTo(selectedRank, anchor: .center) }
                }
            }
        }
        .padding(.init(top: 0, leading: -17, bottom: 0, trailing: -17))
    }
    
    // MARK: - Lego
    private var shadowBackground:some View {
        Color.background
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 3)
            .padding([.leading, .trailing], -100)
    }
    
    private var gradientBackground:some View {
        let stops:[Gradient.Stop] = [
            .init(color: .topDetailViewBackground, location: 0.05),
            .init(color: .topDetailViewBackground1, location: 1)
        ]
        return LinearGradient(stops: stops, startPoint: .bottom, endPoint: .top)
    }
    
    // MARK: -
    private func sessionRank(of session:Session) -> Int {
        sessions.count - Int(sessions.firstIndex(of: session)!)
    }
    
    struct DurationComponents {
        let hr:String
        let min:String
        let sec:String
        
        init(_ hr:String, _ min:String, _ sec:String) {
            self.hr = hr
            self.min = min
            self.sec = sec
        }
    }
}

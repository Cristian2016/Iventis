//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
// References:
// how to detect scroll view stop https://stackoverflow.com/questions/65062590/swiftui-detect-when-scrollview-has-finished-scrolling
//1 reset needle if user deletes history [sessions.isEmpty] and starts bubble again [sessions is 1 now]

import SwiftUI
import MyPackage

struct TopDetailView:View {
    @Binding var needlePosition:Int
    private var sessions: FetchedResults<Session>
    
    @EnvironmentObject private var viewModel:ViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let secretary = Secretary.shared
        
    init?(_ needlePosition:Binding<Int>, _ sessions:FetchedResults<Session>) {
        _needlePosition = needlePosition
        self.sessions = sessions
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            if colorScheme == .light { shadowBackground }
            if colorScheme == .dark { gradientBackground }
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach (sessions) { session in
                            let sessionRank = sessionRank(of: session)
                            ZStack {
                                if shouldShowNeedle(for: session) { selectionNeedle }
                                TopCell(session, sessionRank)
                                    .id(sessionRank)
                                    .needlePosition($needlePosition)
                            }
                        }
                    }
                }
                .onChange(of: needlePosition) { newPosition in
                    withAnimation { proxy.scrollTo(newPosition, anchor: .center) }
                }
                .onChange(of: sessions.count) {
                    if $0 == 1 { needlePosition = -1 }
                } //1
            }
        }
        .padding(.init(top: 0, leading: -17, bottom: 0, trailing: -17))
    }
    
    // MARK: - Lego
    private var selectionNeedle: some View {
        VStack {
            ZStack {
                Image(systemName: "arrowtriangle.down.fill")
                    .foregroundColor(.red)
                    .font(.footnote)
                Divider()
                    .frame(width: 40)
            }
            Spacer()
        }
    }
    
    private var shadowBackground:some View {
        Color.background
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 3)
            .padding([.leading, .trailing], -100)
    }
    
    private var gradientBackground:some View {
        let stops:[Gradient.Stop] = [
            .init(color: .topDetailViewBackground, location: 0.6),
            .init(color: .topDetailViewBackground1, location: 1)
        ]
        return LinearGradient(stops: stops, startPoint: .bottom, endPoint: .top)
    }
    
    // MARK: -
    private func sessionRank(of session:Session) -> Int {
        sessions.count - Int(sessions.firstIndex(of: session)!)
    }
    
    private func shouldShowNeedle(for session:Session) -> Bool {
        let sessionRank = sessionRank(of: session)
        
        if needlePosition == -1, sessionRank  == sessions.count {
            return true
        } else {
            return  sessionRank == needlePosition ? true : false
        }
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

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

struct SessionList:View {
    @Binding var needlePosition:Int
    private var sessions: FetchedResults<Session>
    
    @Environment(\.colorScheme) var colorScheme
            
    init?(_ needlePosition:Binding<Int>, _ sessions:FetchedResults<Session>) {
        _needlePosition = needlePosition
        self.sessions = sessions
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            if colorScheme == .light { shadowBackground }
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach (sessions) { session in
                            let sessionRank = sessionRank(of: session)
                            SessionCell(session, sessionRank)
                                .id(sessionRank)
                                .needlePosition($needlePosition)
                                .overlay(alignment: .top) {
                                    if shouldShowNeedle(for: session) { selectionNeedle }
                                }
                                .overlay { lockLabel(session) }
                        }
                    }
                }
                .onChange(of: needlePosition) { handle(needlePosition: $1, proxy) }
                .onChange(of: sessions.count) { if $1 == 1 { needlePosition = -1 }} //1
            }
            .scrollClipDisabled()
        }
        .padding(.init(top: 0, leading: -4, bottom: 0, trailing: -17))
    }
    
    // MARK: - Lego
    @ViewBuilder
    private func lockLabel(_ session:Session) -> some View {
        if session.isMostRecent {
            Image(systemName: session.isEnded ? "lock.fill" : "lock.open.fill")
                .foregroundStyle(session.isEnded ? .red : .green)
                .contentTransition(.symbolEffect(.replace.downUp))
                .font(.system(size: 20))
                .padding(6)
                .background(.white.shadow(.inner(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)), in: Circle())
                .offset(x: 0, y: -30)
        }
    }
    
    private var selectionNeedle: some View {
        ZStack {
            Image(systemName: "arrowtriangle.down.fill")
                .foregroundStyle(.red)
                .font(.system(size: 20))
            Divider()
                .frame(width: 40)
        }
        .offset(y: -8)
    }
    
    private var shadowBackground:some View {
        Color.background
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 3)
            .padding([.leading, .trailing], -100)
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
    
    private func handle(needlePosition newPosition:Int, _ proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(newPosition == -1 ?
                           sessions.count : newPosition, anchor: .center)
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

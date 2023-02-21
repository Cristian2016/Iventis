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
    
    private let secretary = Secretary.shared
    private static var publisher = NotificationCenter.default.publisher(for: .selectedTab)
        
    init(_ rank:Int?) {
        let predicate:NSPredicate?
        if let rank = rank {
            predicate = NSPredicate(format: "bubble.rank == %i", rank)
        }
        else { predicate = nil }
        
        let descriptor = NSSortDescriptor(key: "created", ascending: false)
        _sessions = FetchRequest(entity: Session.entity(), sortDescriptors: [descriptor], predicate: predicate, animation: .easeInOut)
    }
    
    // MARK: -
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach (sessions) { session in
                        
                        let sessionRank = sessionRank(of: session)
                        
                        TopCell(session, sessionRank)
                            .id(sessionRank)
                            .onTapGesture {
                                UserFeedback.singleHaptic(.medium)
                                postTopCellTappedNotification(for: sessionRank)
                                //use the same rank info you are sending to scroll self in the center
                                withAnimation { proxy.scrollTo(sessionRank, anchor: .center) }
                                
                                delayExecution(.now() + 0.3) {
                                    Secretary.shared.pairBubbleCellNeedsDisplay.toggle()
                                }
                            }
                            .onLongPressGesture {
                                UserFeedback.singleHaptic(.heavy)
                                secretary.sessionToDelete = (session, sessionRank)
                            }
                            .onReceive(TopDetailView.publisher) {
                                let tab = String($0.userInfo!["selectedTab"] as! Int - 1)
                                withAnimation { proxy.scrollTo(tab, anchor: .trailing) }
                            }
                    }
                }
            }
            .background { gradientBackground }
        }
        .padding(.init(top: 0, leading: -17, bottom: 0, trailing: -17))
    }
    
    // MARK: - Lego
    private var gradientBackground:some View {
        LinearGradient(colors: [.topDetailViewBackground1, .topDetailViewBackground], startPoint: .bottom, endPoint: .top)
    }
    
    // MARK: -
    private func sessionRank(of session:Session) -> String {
        String(sessions.count - Int(sessions.firstIndex(of: session)!))
    }
    
    ///send rank information
    private func postTopCellTappedNotification(for rank:String) {
        NotificationCenter.default.post(name: .topCellTapped, object: nil, userInfo: ["topCellTapped":Int(rank)!])
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

struct BubbleDetail_Previews: PreviewProvider {
    static var previews: some View {
        TopDetailView(10)
    }
}

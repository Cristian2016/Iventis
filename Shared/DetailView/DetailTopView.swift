//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailTopView:View {
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
    
    @FetchRequest var sessions:FetchedResults<Session>
    let yOffset = CGFloat(-25)
    let offSetFromBubbleList = CGFloat(-10) //too low it will cut into the bubble list
        
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
                HStack {
                    ForEach (sessions) {
                        let cellRank = sessionRank(of:$0)
                        
                        TopCell($0, sessions.count, cellRank)
                            .id(cellRank)
                            .onTapGesture {
                                //send rank information
                                NotificationCenter.default.post(name: .topCellTapped, object: nil, userInfo: ["topCellTapped":Int(cellRank)!])
                                withAnimation { proxy.scrollTo(cellRank, anchor: .center) }
                            }
                    }
                }
            }
        }
        .offset(x: 0, y: offSetFromBubbleList)
    }
    
    // MARK: -
    private func bubbleColor() -> Color {
        let description = sessions.last?.bubble?.color ?? "mint"
        return (Color.bubbleThrees.filter { $0.description == description }.first ?? Color.Bubbles.mint).sec
        
    }
    
    private func sessionRank(of session:Session) -> String {
        String(sessions.count - Int(sessions.firstIndex(of: session)!))
    }
}

struct BubbleDetail_Previews: PreviewProvider {
    
    static var previews: some View {
        DetailTopView(10)
    }
}

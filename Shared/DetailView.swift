//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
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
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach (sessions) {
                            TopCell($0, sessions.count, sessionRank(of:$0))
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 35, leading: 17, bottom: 0, trailing: 20))
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach (sessions) { session in
                            Rectangle().fill(Color.white)
                                .frame(width: UIScreen.size.width, height: 100)
                        }
                    }
                }
            }
        }
        .offset(x: 0, y: yOffset)
        .padding(-20)
    }
    
    // MARK: -
    private func bubbleColor() -> Color {
        let description = sessions.last?.bubble.color ?? "mint"
        return (Color.bubbleThrees.filter { $0.description == description }.first ?? Color.Bubbles.mint).sec
        
    }
    
    private func sessionRank(of session:Session) -> String {
        String(sessions.count - Int(sessions.firstIndex(of: session)!))
    }
}

struct BubbleDetail_Previews: PreviewProvider {
    
    static var previews: some View {
        DetailView(10)
    }
}

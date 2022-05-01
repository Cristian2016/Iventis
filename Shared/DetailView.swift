//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
    @FetchRequest var sessions:FetchedResults<Session>
        
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
                        ForEach (sessions) { session in
                            VStack (alignment:.leading) {
                                Text(sessionRank(of:session))
                                Text(DateFormatter.bubbleStyleShortDate.string(from: session.created))
                                Text(DateFormatter.bubbleStyleTime.string(from: session.created))
                            }
                            .padding(15)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(bubbleColor(), lineWidth: 4, antialiased: true)
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .offset(x: 0, y: -40)
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

//struct BubbleDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(showDetailView: .constant(true), bubble: .constant(<#T##value: Binding<Bubble>##Binding<Bubble>#>))
//    }
//}

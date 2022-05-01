//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
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
            let color = bubbleColor()
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach (sessions) { session in
                            let duration = sessionDuration(of: session)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(color, lineWidth: 4, antialiased: true)
                                .frame(width: 150, height: 120)
                                HStack {
                                    VStack (alignment:.leading, spacing: 6) {
                                        Text(DateFormatter.bubbleStyleShortDate.string(from: session.created))
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .background(color)
                                            .foregroundColor(.white)
                                        HStack {
                                            Text(duration.hr)
                                            Text(duration.min)
                                            Text(duration.sec)
                                        }
                                    }
                                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                                    Spacer()
                                }
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(sessionRank(of:session))")
                                            .foregroundColor(color)
                                            .font(.title2)
                                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 12))
                                    }
                                    Spacer()
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 35, leading: 17, bottom: 0, trailing: 0))
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
    
    private func sessionDuration(of session:Session) -> (hr:String, min:String, sec:String) {
        let value = session.totalDuration.timeComponents()
        return (String(value.hr), String(value.min), String(value.sec))
    }
                                
}

//struct BubbleDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(showDetailView: .constant(true), bubble: .constant(<#T##value: Binding<Bubble>##Binding<Bubble>#>))
//    }
//}

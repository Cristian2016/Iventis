//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
    @FetchRequest var sessions:FetchedResults<Session>
        
    init(_ predicate:NSPredicate? = nil) {
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
                            VStack {
                                Text("\(session.created)")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

//struct BubbleDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(showDetailView: .constant(true), bubble: .constant(<#T##value: Binding<Bubble>##Binding<Bubble>#>))
//    }
//}

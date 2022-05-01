//
//  BubbleDetail.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.04.2022.
//

import SwiftUI

struct DetailView:View {
    @FetchRequest(entity: Session.entity(), sortDescriptors: [NSSortDescriptor(key: "created", ascending: false)], predicate: nil, animation: Animation.easeInOut)
    private var sessions:FetchedResults<Session>
    
    @Binding var showDetail:Bool
    
    init(_ showDetail:Binding<Bool>) {
        _showDetail = Binding(projectedValue: showDetail)
    }
    
    private func bubble() {
    }
    
    // MARK: -
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack {
                        ForEach (sessions) { session in
                            TopCell().onTapGesture {
                                proxy.scrollTo(2, anchor: .bottom)
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

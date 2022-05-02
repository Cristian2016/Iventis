//
//  DetailBottomView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct DetailBottomView: View {
    @StateObject private var sessionViewModel:SessionViewModel
    
    init(_ sessionRank:Int) {
        _sessionViewModel = StateObject(wrappedValue: SessionViewModel(sessionRank))
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {//each session cooresponding to a list
                ForEach ($sessionViewModel.sessions) { $session in
                    List { //the list of pairs
                        ForEach ($session.pairs_) { $pair in
                            Rectangle()
                                .fill(Color.red)
                        }
                    }
                    .frame(width: 300, height: 200)
                }
            }
        }
    }
}

//struct DetailBottomView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailBottomView(session: .constant(Session()))
//    }
//}

//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct ExitFocusAlertView: View {
    @Binding var predicate:NSPredicate?
    @Binding var showDetail:(show:Bool, rank:Int?)
    
    init(_ predicate:Binding<NSPredicate?>, _ showDetail:Binding<(show:Bool, rank:Int?)>) {
        _predicate = Binding(projectedValue: predicate)
        _showDetail = Binding(projectedValue: showDetail)
    }
    
    var body: some View {
        ZStack {
            Button {
                withAnimation {
                    UserFeedback.triggerSingleHaptic(.medium)
                    predicate = nil
                    showDetail.0 = false
                }
            } label: {
                Label { Text("Exit Detail").font(.title3) }
            icon: { Image(systemName: "eye.slash.fill").font(.title2) }
            }
            .frame(height: 30)
            .tint(.pink)
            .buttonStyle(.bordered)
        }
        .background(Color.background1.padding(-200))
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 4, trailing: 0))
    }
}

//struct SpotlightAlert_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotlightAlertView(.constant(nil), .constant(.))
//    }
//}

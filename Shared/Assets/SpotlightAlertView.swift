//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct SpotlightAlertView: View {
    @Binding var predicate:NSPredicate?
    @Binding var showDetail:(show:Bool, rank:Int?)
    
    init(_ predicate:Binding<NSPredicate?>, _ showDetail:Binding<(show:Bool, rank:Int?)>) {
        _predicate = Binding(projectedValue: predicate)
        _showDetail = Binding(projectedValue: showDetail)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "rays")
                .font(.title)
            Text("Spotlight")
                .font(.title2)
        }
        .foregroundColor(.secondary)
        .padding()
        .onTapGesture { withAnimation {
            UserFeedback.triggerSingleHaptic(.medium)
            predicate = nil
            showDetail.0 = false
        } }
    }
}

//struct SpotlightAlert_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotlightAlertView(.constant(nil), .constant(.))
//    }
//}

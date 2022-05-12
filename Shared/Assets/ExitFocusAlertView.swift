//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct ExitFocusAlertView: View {
    @Binding var predicate:NSPredicate?
    @Binding var showDetailView:Int?
    
    init(_ predicate:Binding<NSPredicate?>, _ showDetailView:Binding<Int?>) {
        _predicate = Binding(projectedValue: predicate)
        _showDetailView = Binding(projectedValue: showDetailView)
    }
    
    var body: some View {
        Button {
            withAnimation {
                UserFeedback.singleHaptic(.medium)
                predicate = nil
                showDetailView = nil
            }
        } label: { Label { Text("Exit Focus").font(.title2) }
            icon: { Image.eyeSlash.font(.title) } }
        .tint(.pink)
        .buttonStyle(.bordered)
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
    }
}

//struct SpotlightAlert_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotlightAlertView(.constant(nil), .constant(.))
//    }
//}

//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct ExitFocusView: View {
    @Binding var predicate:NSPredicate?
    @Binding var showDetailView:Int?
    
    let fontSize = CGFloat(35)
    let topPadding = CGFloat(24)
    static let height = CGFloat(74)
    
    init(_ predicate:Binding<NSPredicate?>, _ showDetailView:Binding<Int?>) {
        _predicate = Binding(projectedValue: predicate)
        _showDetailView = Binding(projectedValue: showDetailView)
    }
    
    var body: some View {
        VStack {
            Button {
                withAnimation {
                    UserFeedback.singleHaptic(.medium)
                    predicate = nil
                    showDetailView = nil
                }
            } label: { Label { Text("Exit Focus").font(.title2) }
                icon: { Image.eyeSlash.font(.system(size: fontSize)) } }
            .tint(.pink)
            .buttonStyle(.bordered)
            .padding(EdgeInsets(top: topPadding, leading: 0, bottom: -5, trailing: 0))
            .background(Rectangle()
                .fill(Color.background1)
                .frame(width: UIScreen.size.width)
                .padding(.bottom, -5)
            )
            .padding()
            Spacer()
        }
        .ignoresSafeArea()
    }
}

//struct SpotlightAlert_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotlightAlertView(.constant(nil), .constant(.))
//    }
//}

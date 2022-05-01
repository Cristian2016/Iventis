//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct SpotlightAlertView: View {
    @Binding var predicate:NSPredicate?
    @Binding var showDetailView:Bool
    
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
            showDetailView = false
        } }
    }
}

struct SpotlightAlert_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightAlertView(predicate: .constant(nil), showDetailView: .constant(false))
    }
}

//
//  EmptyHistoryAlertView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct NoSessionsAlertView: View {
    var body: some View {
        VStack (alignment:.leading) {
            Text("No History")
                .font(.title)
            Text("Tap Seconds\nto Start")
                .foregroundColor(.secondary)
                .font(.system(.title3, design: .monospaced))
        }
        .padding([.top])
        .padding([.top, .leading])
        .padding([.top, .leading])
    }
}

struct NoSessionsAlertView_Previews: PreviewProvider {
    static var previews: some View {
        NoSessionsAlertView()
    }
}

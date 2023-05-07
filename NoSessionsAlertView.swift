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
            Text("No Entries")
                .font(.system(size: 28))
            Text("**Start** \(Image.tap) Tap Seconds")
                .font(.system(size: 22))
                .foregroundColor(.secondary)
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

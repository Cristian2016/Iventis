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
            Text("No Activity")
                .font(.system(size: 28))
            Text("Tap seconds to \(Image.opened) open new session\nTap again to pause\nTouch and hold to \(Image.closed) close")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
        }
        .padding([.top, .leading])
    }
}
struct NoSessionsAlertView_Previews: PreviewProvider {
    static var previews: some View {
        NoSessionsAlertView()
    }
}

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
            Text("\(Image(systemName: "pencil.and.list.clipboard")) No Activity")
                .font(.system(size: 24))
            Text("Tap seconds to \(Image(systemName: "lock.open")) open new session\nTap again to pause\nTouch and hold to \(Image(systemName: "lock")) close")
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

//
//  EmptyHistoryAlertView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct NoActivityAlertView: View {
    var body: some View {
        let showAll = SmallHelpOverlay.Model.shared.topmostView != .assistUser
        
        VStack (alignment:.leading) {
            Text("No Activity")
                .font(.system(size: 28))
            
            if showAll {
                Text("Tap seconds to \(Image.opened) open new session\nTap again to pause\nTouch and hold to \(Image.closed) close")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            } else {
                Text("Follow steps provided below. Shake device to show \(Image.help) help. At any time!")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
        }
        .padding([.top, .leading])
    }
}
struct NoSessionsAlertView_Previews: PreviewProvider {
    static var previews: some View {
        NoActivityAlertView()
    }
}

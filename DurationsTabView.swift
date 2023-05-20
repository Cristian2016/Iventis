//
//  DurationTabView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.05.2023.
//

import SwiftUI

struct DurationsTabView: View {
    @State private var tab = 1
    let bubble:Bubble
    
    var body: some View {
        TabView(selection: $tab) {
            VStack {
                DurationsView(bubble)
                Spacer()
            }
            
            Circle()
            Rectangle()
        }
        .tabViewStyle(.page)
        .frame(height: 330)
//        .background()
    }
}

struct DurationsTabView_Previews: PreviewProvider {
    static var previews: some View {
        DurationsTabView(bubble: ActionsView_Previews.bubble)
    }
}

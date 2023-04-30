//
//  WidgetSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.04.2023.
//

import SwiftUI

struct WidgetSymbol: View {
    @State private var show = false
    let rank:Int64
    
    var body: some View {
        ZStack {
            if show {
                Image(systemName: "w.circle.fill")
                    .font(.system(size: 16))
            }
        }
        .onReceive(Secretary.shared.$mostRecentlyUsedBubble) { output in
            show = rank == output ? true : false
        }
    }
}

struct WidgetSymbol_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSymbol(rank: 20)
    }
}

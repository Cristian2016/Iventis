//
//  WidgetSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.04.2023.
//

import SwiftUI
import WidgetKit

struct WidgetSymbol: View {
    @State private var show = false
    let rank:Int64
    
    var body: some View {
        ZStack {
            if show {
                Image(systemName: "w.circle.fill")
                    .foregroundColor(.pauseStickerColor)
                    .font(.system(size: 16))
            }
        }
        .onReceive(Secretary.shared.$widgetsExist) { output in
            show = (output && Secretary.shared.mostRecentlyUsedBubble == rank) ? true : false
        }
        .onReceive(Secretary.shared.$mostRecentlyUsedBubble) { output in
            //widget exists and it's meant for this widgetSymbol (with the rank)
            let condition = output == rank && Secretary.shared.widgetsExist
            
            show = condition ? true : false
        }
    }
}

struct WidgetSymbol_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSymbol(rank: 20)
    }
}

//
//  WidgetSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.04.2023.
//

import SwiftUI
import WidgetKit

struct WidgetSymbol: View {
    private var show:Bool {
        let thisBubbleHasWidget = secretary.mostRecentlyUsedBubble == rank
        return secretary.widgetsExist && thisBubbleHasWidget ? true : false
    }
    let rank:Int64
    
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if show {
                Image(systemName: "w.circle.fill")
                    .foregroundStyle(Color.pauseStickerColor)
                    .font(.system(size: 16))
            }
        }
    }
}

struct WidgetSymbol_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSymbol(rank: 20)
    }
}

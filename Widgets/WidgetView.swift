//
//  WidgetView.swift
//  WidgetsExtension
//
//  Created by Cristian Lapusan on 27.04.2023.
//

import SwiftUI

//what shows onscreen
struct WidgetView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Circle()
            .fill(.regularMaterial)
            .overlay {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(2.2, contentMode: .fit)
                    .overlay {
                        display
                            .padding([.leading, .trailing], 3)
                            .font(.title3)
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                    }
            }
    }
    
    @ViewBuilder
    private var display:some View {
        if entry.isRunning {
            Text(Date().addingTimeInterval(TimeInterval(entry.currentClock)), style: .timer)
        } else {
            if entry.currentClock <= 0 { Text(Image.checkmark) }
            else { Text(String(entry.currentClock.timerTitle)) }
        }
    }
}

//struct WidgetsEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetsEntryView(entry: .init(date: Date(), configuration: .init()))
//    }
//}

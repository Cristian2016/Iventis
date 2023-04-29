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
        if entry.input.isRunning {
            Text(Date().addingTimeInterval(entry.input.startValue), style: .timer)
        } else {
            if entry.input.startValue <= 0 && entry.input.isTimer { Text(Image.checkmark) }
            else { Text(String(Float(abs(entry.input.startValue)).widget)) }
        }
    }
}

//struct WidgetsEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetsEntryView(entry: .init(date: Date(), configuration: .init()))
//    }
//}

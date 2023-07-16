//
//  WidgetView.swift
//  WidgetsExtension
//
//  Created by Cristian Lapusan on 27.04.2023.
//⚠️ 1 remove this and widget does not show up

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
            .containerBackground(.clear, for: .widget) //⚠️ 1
    }
    
    @ViewBuilder
    private var display:some View {
        if let input = entry.input {
            if input.isRunning {
                Text(Date().addingTimeInterval(input.startValue), style: .timer)
            } else {
                if input.startValue <= 0 && input.isTimer { Text(Image.checkmark) }
                else { Text(String(Float(abs(input.startValue)).widgetFormat)) }
            }
        } else {
            Image(systemName: "line.diagonal")
        }
    }
}

struct WidgetsEntryView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: Provider.Entry(date: Date(), input: nil))
    }
}

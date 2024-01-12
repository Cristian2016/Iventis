//
//  Widget.swift
//  Widgets
//
//  Created by Cristian Lapusan on 18.01.2024.
//

import WidgetKit
import SwiftUI

public extension Float {
    struct Components {
        let hr:Int
        let min:Int
        let sec:Int
        let hundredths:Int
        
        static let zeroAll = Components(hr: 0, min: 0, sec: 0, hundredths: 0)
    }
    
    var components:Components {
        if self == 0 { return .zeroAll }
        
        let decimalValue = Int(self) //used to compute hr. min, sec
//        let fractionalValue = Int((self - Float(decimalValue))*100)
        var fractionalValue = Int(((self - Float(decimalValue)) * 100).rounded(.toNearestOrEven))
        
        var addedToSec = 0
        if fractionalValue == 100 {
            fractionalValue = 0
            addedToSec = 1
        }
        
        //how many full hours
        let hr = decimalValue/3600
        //hours remaining
        let hrRemaining = decimalValue%3600
        
        //how many full minutes
        let min = hrRemaining/60
        //remaining
        let sec = hrRemaining%60 + addedToSec
        
        return Components(hr: hr, min: min, sec: sec, hundredths: fractionalValue)
    }
    
    var widgetFormat:String {
        //minutes 0 if no hours, 00 if there are hours
        let components = self.components
        
        let hr = components.hr != 0 ? String(components.hr) + ":" : ""
        let min = (components.min != 0) ? String(format: "%.2d", components.min)  + ":" : "00:"
        let sec = String(format: "%.2d", components.sec)
        return hr + min + sec
    }
}

struct Widgets: Widget {
    let kind: String = "Fused"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Activity")
        .description("Shows activity of most recently used bubble")
        .supportedFamilies([.accessoryCircular])
    }
}

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
                if input.startValue <= 0 && input.isTimer { Text(Image(systemName: "checkmark")) }
                else { Text(String(Float(abs(input.startValue)).widgetFormat)) }
            }
        } else {
            Image(systemName: "line.diagonal")
        }
    }
}

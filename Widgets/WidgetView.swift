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
                    .padding()
                    .overlay {
                        Text(Date(), style: .timer)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.01)
                    }
            }
    }
}

//struct WidgetsEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetsEntryView(entry: .init(date: Date(), configuration: .init()))
//    }
//}

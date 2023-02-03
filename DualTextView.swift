//
//  DualTextView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.02.2023.
//

import SwiftUI

///2 text views side by side. ex: 12h
struct DualTextView: View {
    struct Content {
        let text1:String
        let text2:String
    }
    
    struct Metrics {
        let font1Size:Font
        let font2Size:Font
        
        static let durationPicker = Metrics(font1Size: .largeTitle, font2Size: .title2)
    }
    
    let content:Content
    var metrics:Metrics =  Metrics(font1Size: .title, font2Size: .title2)
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(content.text1).font(metrics.font1Size)
            Text(content.text2).font(metrics.font2Size)
        }
    }
}

struct DualTextView_Previews: PreviewProvider {
    static var previews: some View {
        DualTextView(content: .init(text1: "Pula", text2: "Mea"))
    }
}

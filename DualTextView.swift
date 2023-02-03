//
//  DualTextView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.02.2023.
//

import SwiftUI

///2 text views side by side. ex: 12h
struct DualTextView: View {
    struct Metrics {
        let font1Size:Font
        let font2Size:Font
    }
    
    var metrics:Metrics =  Metrics(font1Size: .title, font2Size: .title2)
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("23").font(metrics.font1Size)
            Text("h").font(metrics.font2Size)
        }
    }
}

struct DualTextView_Previews: PreviewProvider {
    static var previews: some View {
        DualTextView()
    }
}

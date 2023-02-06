//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsView1: View {
    let bubble:Bubble
    @State private var startDelay:Int64?
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            BlurryBackground(material: .thinMaterial)
            Color.white.cornerRadius(metrics.radius)
                .padding()
                .padding()
        }
    }
    
    struct Metrics {
        let radius = CGFloat(20)
    }
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        bubble.color = "darkGreen"
        return bubble
    }()
    static var previews: some View {
        MoreOptionsView1(bubble: bubble)
    }
}

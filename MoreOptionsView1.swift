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
        GeometryReader { geo in
            let isPortrait = geo.size.height > geo.size.width
            let layout = isPortrait ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
            
            ZStack {
                BlurryBackground(material: .ultraThinMaterial)
                Color.white
                    .cornerRadius(metrics.radius)
                    .standardShadow()
                    .overlay {
                        layout {
                            ScrollView {
                                LazyVGrid(columns: metrics.columns) {
                                    ForEach(Color.triColors) { tricolor in
                                        ZStack {
                                            Circle()
                                            tricolor.sec
                                        }
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                        .padding(10)
                    }
                    .padding()
                    .padding()
            }
        }
    }
    
    struct Metrics {
        let /* background */radius = CGFloat(10)
        let columns = Array(repeating: GridItem(), count: 3)
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

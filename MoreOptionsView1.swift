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
            let bubbleColor = Color.bubbleColor(forName: bubble.color)
            
            ZStack {
                BlurryBackground(material: .ultraThinMaterial)
                Color.white
                    .cornerRadius(metrics.radius)
                    .standardShadow()
                    .overlay {
                        layout {
                            HStack(spacing: 4) {
                                ForEach(Bubble.delays, id:\.self) { delay in
                                    Button {
                                        
                                    } label: {
                                        bubbleColor
                                            .aspectRatio(4/3, contentMode: .fit)
                                            .overlay {
                                                Text(String(delay))
                                                    .foregroundColor(.white)
                                                    .font(Font.system(size: 30).weight(.medium))
                                            }
                                    }
                                }
                            }
                            Divider()
                            ScrollView {
                                LazyVGrid(columns: metrics.columns, spacing: 4) {
                                    ForEach(Color.triColors) { tricolor in
                                        ZStack {
                                            Circle()
                                            tricolor.sec
                                        }
                                        .aspectRatio(isPortrait ? 3/2 : 3/1, contentMode: .fit)
                                    }
                                }
                            }
                            .frame(minWidth: 330)
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

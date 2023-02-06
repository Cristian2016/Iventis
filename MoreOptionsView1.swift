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
            
            let columns =  Array(repeating: GridItem(spacing: metrics.spacing), count: 3)
            let isPortrait = geo.size.height > geo.size.width
            let layout = isPortrait ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(alignment: .top))
            let bubbleColor = Color.bubbleColor(forName: bubble.color)
            
            ZStack {
                BlurryBackground(material: .ultraThinMaterial)
                layout {
                    VStack {
                        Text("Start Delay")
                        HStack(spacing: metrics.spacing) {
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
                    }
                    Divider()
                    ScrollView {
                        Text(Color.userFriendlyBubbleColorName(for: bubble.color))
                        LazyVGrid(columns: columns, spacing: metrics.spacing) {
                            ForEach(Color.triColors) { tricolor in
                                ZStack {
                                    Circle()
                                    tricolor.sec
                                }
                                .aspectRatio(isPortrait ? 3/2 : 3/1, contentMode: .fit)
                            }
                        }
                    }
                    .frame(minWidth: metrics.minWidth)
                    .scrollIndicators(.hidden)
                }
                .padding(8)
                .padding([.top, .bottom])
                .background {
                    Color
                        .white
                        .cornerRadius(20)
                        .standardShadow(0.2)
                }
                .padding()
                .padding()
            }
        }
    }
    
    struct Metrics {
        let /* background */radius = CGFloat(10)
        
        let minWidth = CGFloat(300)
        let spacing = CGFloat(4)
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

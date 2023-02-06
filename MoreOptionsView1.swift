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
    let bubbleColor:Color
    @State private var startDelay = Int(0)
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        self.bubbleColor = Color.bubbleColor(forName: bubble.color)
        
        if let initialDelay = bubble.sdb?.referenceDelay {
            self.startDelay = Int(initialDelay)
        }
    }
    
    let metrics = Metrics()
    
    var body: some View {
        GeometryReader { geo in
            let isPortrait = geo.size.height > geo.size.width
            let layout = isPortrait ?
            AnyLayout(VStackLayout()) : .init(HStackLayout(alignment: .top))
            
            ZStack {
                BlurryBackground(material: .ultraThinMaterial)
                layout {
                    VStack(spacing: metrics.vStackSpacing) {
                        startDelayDisplay
                        digits
                    }
                    
                    Divider().frame(height: 200)
                    
                    VStack(spacing: metrics.vStackSpacing) {
                        colorNameView
                        colors
                    }
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
    
    // MARK: - Lego
    private var startDelayDisplay:some View {
        HStack {
            Text("Start Delay")
            if let delay = startDelay {
                Text(String(delay))
            }
        }
        .padding([.leading, .trailing])
        .background(bubbleColor, in: RoundedRectangle(cornerRadius: 4))
        .foregroundColor(.white)
        .font(metrics.font)
    }
    
    private var digits:some View {
        HStack(spacing: metrics.spacing) {
            ForEach(Bubble.delays, id:\.self) { delay in
                Button {
                    startDelay += delay
                } label: {
                    
                    bubbleColor
                        .aspectRatio(metrics.colorRatio, contentMode: .fit)
                        .overlay {
                            Text(String(delay))
                                .foregroundColor(.white)
                                .font(metrics.font)
                        }
                }
            }
        }
    }
    
    private var colorNameView:some View {
        Text(Color.userFriendlyBubbleColorName(for: bubble.color))
            .padding([.leading, .trailing])
            .background(bubbleColor, in: RoundedRectangle(cornerRadius: 4))
            .foregroundColor(.white)
            .font(metrics.font)
    }
    
    private var colors:some View {
        let columns =  Array(repeating: GridItem(spacing: metrics.spacing), count: 3)
        return ScrollView {
            LazyVGrid(columns: columns, spacing: metrics.spacing) {
                ForEach(Color.triColors) { tricolor in
                    ZStack {
                        Circle()
                            .aspectRatio(metrics.colorRatio, contentMode: .fit)
                        tricolor.sec
                            .overlay {
                                if tricolor.sec == bubbleColor {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(metrics.font)
                                }
                            }
                    }
                    
                }
            }
        }
        .scrollIndicators(.hidden)
//        .background(.red)
        .frame(maxHeight: 306)
    }
    
    // MARK: -
    struct Metrics {
        let radius = CGFloat(10)
        
        let minWidth = CGFloat(300)
        let spacing = CGFloat(4)
        let font = Font.system(size: 30, weight: .medium)
        let colorRatio = CGFloat(1/0.64)
                
        let vStackSpacing = CGFloat(8)
    }
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        bubble.color = "darkGreen"
        return bubble
    }()
    static var previews: some View {
        MoreOptionsView1(bubble)
    }
}

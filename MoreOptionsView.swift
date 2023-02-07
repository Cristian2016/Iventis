//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsView: View {
    let bubble:Bubble
    let bubbleColor:Color
    @EnvironmentObject var viewModel:ViewModel
    @State private var userEnteredDelay:Int
    private var initialStartDelay = 0
        
    init(_ bubble:Bubble) {
        self.bubble = bubble
        self.bubbleColor = Color.bubbleColor(forName: bubble.color)
        
        let refDelay = bubble.sdb?.referenceDelay
        self.userEnteredDelay = Int(refDelay!)
        self.initialStartDelay = Int(refDelay!)
        self.metrics = Metrics()
    }
    
    var metrics:Metrics
    
    var body: some View {
        GeometryReader { geo in
            let isPortrait = geo.size.height > geo.size.width
            let layout = isPortrait ?
            AnyLayout(VStackLayout()) : .init(HStackLayout(alignment: .top))
            
            ZStack {
                BlurryBackground(material: .ultraThinMaterial)
                    .onTapGesture { saveDelay() }
                    .highPriorityGesture(swipeLeft)
                    .ignoresSafeArea()
                
                layout {
                    VStack(alignment: .leading, spacing: 14) {
                        startDelayDisplay
                        digits
                    }
                    
                    Divider()
                    Color.clear
                        .overlay {
                            ColorsGrid(spacing: 0) {  }
                        }
                }
                .padding(10)
                .background {
                    Color.white
                        .cornerRadius(10)
                        .standardShadow()
                }
                .padding()
                .padding()
            }
        }
    }
    
    // MARK: - Lego
    private var startDelayDisplay:some View {
        HStack(alignment: .firstTextBaseline) {
            Text(String(userEnteredDelay))
                .padding([.leading, .trailing])
                .foregroundColor(.white)
                .font(metrics.delayFont)
                .layoutPriority(1)
            Text("\(Image.startDelay) Start Delay")
                .font(.caption)
                .foregroundColor(.white)
        }
        .background(bubbleColor, in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var digits:some View {
        HStack(spacing: metrics.spacing) {
            ForEach(Bubble.delays, id:\.self) { delay in
                Button {
                    userEnteredDelay += delay
                } label: {
                    
                    Circle().fill(bubbleColor)
                        .overlay {
                            Text(String(delay))
                                .foregroundColor(.white)
                                .font(metrics.digitFont)
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
    
    private var checkmark:some View {
        Image(systemName: "checkmark")
            .foregroundColor(.white)
            .font(metrics.font)
    }
    
    
    // MARK: -
    struct Metrics {
        let radius = CGFloat(10)
        
        let minWidth = CGFloat(300)
        let spacing = CGFloat(4)
        
        let delayFont = Font.system(size: 30, weight: .light)
        let font = Font.system(size: 30, weight: .medium)
        let digitFont = Font.system(size: 34)
        
        let portraitColorRatio = CGFloat(1.9)
        let landscapeColorRatio = CGFloat(2.54)
                
        let vStackSpacing = CGFloat(8)
        
        var columns:[GridItem] { Array(repeating: GridItem(spacing: spacing), count: 3) }
    }
    
    // MARK: -
    var swipeLeft:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { _ in
                if userEnteredDelay != 0 {
                    UserFeedback.doubleHaptic(.heavy)
                    userEnteredDelay = 0
                }
            }
    }
    
    // MARK: -
    func dismiss() { viewModel.theOneAndOnlyEditedSDB = nil }
    
    func saveDelay() {
        /*
         if user sets a new start delay
         save delay
         save CoreData context*/
        if initialStartDelay != userEnteredDelay {
            UserFeedback.singleHaptic(.medium)
            viewModel.saveDelay(for: bubble, userEnteredDelay)
        }
        dismiss()
    }
    
    func saveColor(to colorName: String) {
        viewModel.saveColor(for: bubble, to: colorName)
        dismiss()
    }
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        let sdb = StartDelayBubble(context: PersistenceController.preview.viewContext)
        sdb.referenceDelay = 0
        
        bubble.sdb = sdb
        bubble.color = "darkGreen"
        return bubble
    }()
    static var previews: some View {
        MoreOptionsView(bubble)
    }
}

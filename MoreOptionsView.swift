//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsView: View {
    struct EmptyStruct {
        var bubble:Bubble
        var initialBubbleColor:Color
        var initialStartDelay:Int
        var userEnteredDelay:Int
    }
    
    @State private var emptyStruct:EmptyStruct?
        
    @EnvironmentObject var viewModel:ViewModel
    private let secretary = Secretary.shared
            
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            if let emptyStruct = emptyStruct {
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
                            if emptyStruct.bubble.state != .running {
                                VStack(alignment: .leading, spacing: 14) {
                                    startDelayDisplay
                                    digits
                                    
                                    if !isPortrait {
                                        if emptyStruct.userEnteredDelay != 0 {
                                            Text("**Save** \(Image(systemName: "hand.tap")) Tap outside frame")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                            
                                            Text("**Remove** \(Image(systemName: "arrow.left.circle.fill")) Swipe outside frame")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("**Dismiss** \(Image(systemName: "hand.tap")) Tap outside frame")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                            
                            Color.clear
                                .overlay { ColorsGrid(emptyStruct.bubble, spacing: 0) { saveDelay() }}
                        }
                        .padding(10)
                        .background {
                            Color.white
                                .cornerRadius(10)
                                .standardShadow()
                        }
                        .padding(isPortrait ? 28 : 20)
                    }
                }
            }
        }
        .onReceive(secretary.$theOneAndOnlyEditedSDB) {
            if let sdb = $0, let bubble = sdb.bubble {
                let color = Color.bubbleColor(forName: bubble.color)
                let initialStartDelay = Int(sdb.referenceDelay)
                
                emptyStruct = EmptyStruct(bubble: bubble,
                                          initialBubbleColor: color,
                                          initialStartDelay: initialStartDelay,
                                          userEnteredDelay: initialStartDelay)
                
            } else {
                emptyStruct = nil
            }
        }
    }
    
    // MARK: - Lego
    private var startDelayDisplay:some View {
        HStack(alignment: .firstTextBaseline) {
            Text(String(emptyStruct!.userEnteredDelay) + "s")
                .padding([.leading, .trailing])
                .foregroundColor(.white)
                .font(metrics.delayFont)
                .layoutPriority(1)
            Text("\(Image.startDelay) Start Delay")
                .font(.callout)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.head)
        }
        .padding([.trailing], 8)
        .background(emptyStruct!.initialBubbleColor, in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var digits:some View {
        HStack(spacing: metrics.spacing) {
            ForEach(Bubble.delays, id:\.self) { delay in
                Button {
                    emptyStruct!.userEnteredDelay += delay
                } label: {
                    
                    Circle().fill(emptyStruct!.initialBubbleColor)
                        .overlay {
                            Text(String(delay))
                                .foregroundColor(.white)
                                .font(metrics.digitFont)
                        }
                }
            }
        }
    }
    
    // MARK: -
    struct Metrics {
        let radius = CGFloat(10)
        
        let minWidth = CGFloat(300)
        let spacing = CGFloat(4)
        
        let delayFont = Font.system(size: 70, design: .rounded)
        let font = Font.system(size: 30, weight: .medium)
        let digitFont = Font.system(size: 38, weight: .medium, design: .rounded)
        
        let portraitColorRatio = CGFloat(1.9)
        let landscapeColorRatio = CGFloat(2.54)
                
        let vStackSpacing = CGFloat(8)
        
        var columns:[GridItem] { Array(repeating: GridItem(spacing: spacing), count: 3) }
    }
    
    // MARK: -
    var swipeLeft:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { _ in
                if emptyStruct!.userEnteredDelay != 0 {
                    UserFeedback.doubleHaptic(.heavy)
                    emptyStruct!.userEnteredDelay = 0
                }
            }
    }
    
    // MARK: -
    func dismiss() { secretary.theOneAndOnlyEditedSDB = nil }
    
    func saveDelay() {
        /*
         if user sets a new start delay
         save delay
         save CoreData context*/
        if emptyStruct!.initialStartDelay != emptyStruct!.userEnteredDelay {
            UserFeedback.singleHaptic(.medium)
            viewModel.saveDelay(for: emptyStruct!.bubble, emptyStruct!.userEnteredDelay)
        }
        dismiss()
    }
    
    func saveColor(to colorName: String) {
        viewModel.saveColor(for: emptyStruct!.bubble, to: colorName)
        //dimiss will be called separately
    }
}

//struct MoreOptionsView1_Previews: PreviewProvider {
//    static let bubble:Bubble = {
//        let bubble = Bubble(context: PersistenceController.preview.viewContext)
//        let sdb = StartDelayBubble(context: PersistenceController.preview.viewContext)
//        sdb.referenceDelay = 0
//
//        bubble.sdb = sdb
//        bubble.color = "sourCherry"
//        return bubble
//    }()
//    static var previews: some View {
//        MoreOptionsView(emptyStruct.bubble)
//    }
//}

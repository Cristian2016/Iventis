//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//  to avoid @Published property View body evaluate over and over again for Observableobject, I found an approach that seems to work just great. I use onReceive to get publisher.output and use it to sort of instantiate MoreOptionsView struct. It's already instantiated technically, but it's invisible in the ViewHierarchy. using received publisher output I set the @State input struct and that triggers a view redraw and it will show up ob the screen

import SwiftUI
import MyPackage

struct MoreOptionsView: View {
    struct Input {
        var bubble:Bubble
        var initialBubbleColor:Color
        var initialStartDelay:Int
        var userEditedDelay:Int
    }
    
    //set within .onReceive closure. all the information MoreOptionView needs :)
    @State private var input:Input?
        
    @EnvironmentObject var viewModel:ViewModel
    private let secretary = Secretary.shared
            
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            if let emptyStruct = input {
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
                                VStack(alignment: .trailing, spacing: 14) {
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        startDelayDisplay
                                        digits
                                    }
                                    
                                    if !isPortrait {
                                        if emptyStruct.userEditedDelay != 0 {
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
                                .overlay { ColorsGrid(emptyStruct.bubble, spacing: 4) { saveDelay() }}
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
        .onReceive(secretary.$moreOptionsBuble) {
            if let bubble = $0 {
                let color = Color.bubbleColor(forName: bubble.color)
                let initialStartDelay = Int(bubble.startDelay)
                
                input = Input(bubble: bubble,
                              initialBubbleColor: color,
                              initialStartDelay: initialStartDelay,
                              userEditedDelay: initialStartDelay)
                
            } else { input = nil }
        }
    }
    
    // MARK: - Lego
    private var startDelayDisplay:some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Start Delay")
                .font(.callout)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .truncationMode(.head)
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(String(input!.userEditedDelay))
                    .font(metrics.delayFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .layoutPriority(10)
                Text("s")
                    .font(.callout)
            }
        }
    }
    
    private var digits:some View {
        HStack(spacing: metrics.spacing) {
            ForEach(Bubble.delays, id:\.self) { delay in
                Button {
                    input!.userEditedDelay += delay
                } label: {
                    
                    RoundedRectangle(cornerRadius: 4).fill(input!.initialBubbleColor)
                        .aspectRatio(1, contentMode: .fit)
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
        
        let delayFont = Font.system(size: 80, design: .rounded)
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
                if input!.userEditedDelay != 0 {
                    UserFeedback.doubleHaptic(.heavy)
                    input!.userEditedDelay = 0
                }
            }
    }
    
    // MARK: -
    func dismiss() { secretary.moreOptionsBuble = nil }
    
    func saveDelay() {
        /*
         if user sets a new start delay
         save delay
         save CoreData context*/
        if input!.initialStartDelay != input!.userEditedDelay {
            UserFeedback.singleHaptic(.medium)
        }
        dismiss()
    }
    
    func saveColor(to colorName: String) {
        viewModel.changeColor(of: input!.bubble, to: colorName)
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

//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//  to avoid @Published property View body evaluate over and over again for Observableobject, I found an approach that seems to work just great. I use onReceive to get publisher.output and use it to sort of instantiate MoreOptionsView struct. It's already instantiated technically, but it's invisible in the ViewHierarchy. using received publisher output I set the @State input struct and that triggers a view redraw and it will show up ob the screen

import SwiftUI
import MyPackage

struct MoreOptionsView: View {
    //set within .onReceive closure. all the information MoreOptionView needs :)
    @State private var input:Input?
    @Environment(NewViewModel.self) private var newViewModel
        
    private let secretary = Secretary.shared
            
    private let metrics = Metrics()
    
    var body: some View {
        ZStack {
            if let input = input {
                GeometryReader { geo in
                    let isPortrait = geo.size.height > geo.size.width
                    
                    let layout = isPortrait ?
                    AnyLayout(VStackLayout()) : .init(HStackLayout(alignment: .top))
                    
                    ZStack {
                        Background(.material(.ultraThick))
                            .onTapGesture { saveDelay() }
                            .highPriorityGesture(swipeLeft)
                        
                        layout {
                            if input.bubble.state != .running {
                                VStack(alignment: .trailing, spacing: 14) {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        display
                                        digits
                                    }
                                }
                                
                                Divider()
                            }
                            
                            ColorsGrid(input.bubble) { saveDelay() }
                        }
//                        .frame(maxHeight: 700)
//                        .background {
//                            vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 10)
//                                .fill(.thickMaterial)
//                                .standardShadow()
//                        }
                        .padding(isPortrait ? 28 : 20)
                    }
                }
            }
            Info(input)
        }
        .onChange(of: newViewModel.moreOptionsBubble) { _, newValue in
            if let bubble = newValue {
                let color = Color.bubbleColor(forName: bubble.color)
                let initialStartDelay = Int(bubble.startDelayBubble?.initialClock ?? 0)
                                                
                input = Input(bubble: bubble,
                              initialBubbleColor: color,
                              initialStartDelay: initialStartDelay,
                              userEditedDelay: initialStartDelay)
                
            } else { input = nil }
        }
    }
    
    // MARK: -
    private var swipe:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                if input!.userEditedDelay != 0 {
                    UserFeedback.doubleHaptic(.heavy)
                    input!.userEditedDelay = 0
//                    viewModel.removeStartDelay(for: input?.bubble)
                }
            }
    }
    
    // MARK: - Lego
    private var display:some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .firstTextBaseline) {
                Spacer()
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
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { saveDelay() }
            .gesture(swipe) //remove delay
        }
    }
    
    private var digits:some View {
        HStack(spacing: metrics.digitSpacing) {
            ForEach(Bubble.delays, id:\.self) { delay in
                Button {
                    UserFeedback.singleHaptic(.light)
                    input!.userEditedDelay += delay
                } label: { digitLabel(delay) }
            }
        }
    }
    
    private func digitLabel(_ delay: Int) -> some View {
        input!.initialBubbleColor
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Text(String(delay))
                    .font(metrics.digitFont)
                    .foregroundColor(.white)
            }
    }
    
    // MARK: -
    private struct Metrics {
        let radius = CGFloat(10)
        
        let minWidth = CGFloat(300)
        let digitSpacing = CGFloat(2)
        let colorsSpacing = CGFloat(4)
        
        let delayFont = Font.system(size: 80, design: .rounded)
        let font = Font.system(size: 30, weight: .medium)
        let digitFont = Font.system(size: 38, weight: .medium, design: .rounded)
        let infoFont = Font.system(size: 20)
        
        let portraitColorRatio = CGFloat(1.9)
        let landscapeColorRatio = CGFloat(2.54)
                
        let vStackSpacing = CGFloat(8)
        
        var columns:[GridItem] { Array(repeating: GridItem(spacing: 0), count: 3) }
    }
    
    // MARK: -
    private var swipeLeft:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { _ in
                if input!.userEditedDelay != 0 {
                    UserFeedback.doubleHaptic(.heavy)
                    input!.userEditedDelay = 0
//                    viewModel.removeStartDelay(for: input?.bubble)
                }
            }
    }
    
    // MARK: -
    private func dismiss() { newViewModel.moreOptionsBubble = nil }
    
    private func saveDelay() {
        /*
         if user sets a new start delay
         save delay
         save CoreData context */
        if input!.initialStartDelay != input!.userEditedDelay && input!.userEditedDelay != 0 {
            UserFeedback.singleHaptic(.medium)
//            viewModel.setStartDelay(Float(input!.userEditedDelay), for: input?.bubble)
        }
        dismiss()
    }
    
    private func saveColor(to colorName: String) {
//        viewModel.changeColor(of: input!.bubble, to: colorName)
        //dimiss will be called separately
    }
}

extension MoreOptionsView {
    struct Input {
        var bubble:Bubble
        var initialBubbleColor:Color
        var initialStartDelay:Int
        var userEditedDelay:Int
    }
    
    struct Info: View {
        private let input:Input
        @State private var show = false
        let metrics = Metrics()
        
        private var delayAsString:String {
            input.userEditedDelay == 0 ? "" : String(input.userEditedDelay)
        }
        
        init?(_ input:Input?) {
            guard let input = input else { return nil }
            self.input = input
        }
        
        var body: some View {
            ZStack {
                let title = "Start Delay"
                let subtitle:LocalizedStringKey = "Start automatically after a number of seconds"
                
                if show {
                    Background(.dark()).ignoresSafeArea()
                    
                    MaterialLabel(title, subtitle) { MoreOptionsInfoView() } _: { showInfo() } _: { }
                }
            }
            .onReceive(Secretary.shared.$showMoreOptionsInfo) { output in
                withAnimation { show = output }
            }
        }
        
        struct Metrics {
            let font = Font.system(size: 30, weight: .medium)
            let infoFont = Font.system(size: 20)
        }
        
        private func showInfo() {
            withAnimation {
                Secretary.shared.showMoreOptionsInfo = false
            }
        }
    }
}

struct SmallDigit:ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .scaleEffect(x: pressed ? 0.9 : 1.0, y: pressed ? 0.9 : 1.0)
            .opacity(pressed ? 0.3 : 1.0)
    }
}

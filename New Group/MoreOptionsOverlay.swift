//
//  MOV.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.07.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsOverlay: View {
    private let startDelays = [5, 10, 20, 45]
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let bubble:Bubble
    @State private var displayedStartDelay = 0
    
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
    }
    
    private let metrics = Metrics()
    
    var body: some View {
        
        let isRegular = verticalSizeClass == .regular
        
        ZStack {
            Background(.dark(.Opacity.overlay))
                .onTapGesture {
                    viewModel.saveStartDelay(bubble)
                    viewModel.reset()
                }
                .overlay(alignment: .top) { ControlOverlay.BubbleLabel(.hasBubble(bubble)) }
            
            OverlayScrollView {
                let layout = isRegular ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(alignment: .top))
                
                layout {
                    VStack(spacing: 4) {
                        if !bubble.isRunning {
                            display
                            digits
                        }
                    }
                    colorGrid
                }
                .onAppear { //⚠️ can be called multiple times, not just once
                    self.displayedStartDelay = Int(bubble.delayBubble?.initialDelay ?? 0)
                }
                .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: isRegular ? 360 : .infinity)
                .compositingGroup()
                .standardShadow()
            } action: {
                viewModel.saveStartDelay(bubble)
                viewModel.reset()
            }
        }
        .swipeToClear(removeDelay)
    }
    
    // MARK: - LEGO
    private var display:some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
            Text("Start Delay")
                .font(.system(size: 30))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .truncationMode(.head)
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(String(displayedStartDelay))
                    .font(metrics.delayFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .layoutPriority(10)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.saveStartDelay(bubble)
            viewModel.reset()
        }
        .frame(height: .Overlay.displayHeight)
    }
    
    private var digits:some View {
        HStack(spacing: metrics.digitSpacing) {
            ForEach(startDelays, id:\.self) { startDelay in
                Button { userTappedDigit(startDelay) } label: { digitTitle(startDelay) }
            }
        }
        .foregroundStyle(Color.label2)
    }
    
    private func userTappedDigit(_ delay:Int) {
        UserFeedback.singleHaptic(.light)
        displayedStartDelay += delay
        viewModel.userEnteredStartDelay = Float(displayedStartDelay)
    }
    
    private func digitTitle(_ delay: Int) -> some View {
        Circle()
            .fill(Color.background)
            .overlay {
                VanishingUnderlabel {
                    Text(String(delay))
                        .font(.digitFont)
                } bottom: {
                    if delay == 5 {
                        Text("Sec")
                            .font(.system(size: 14))
                    }
                }
                
            }
    }
    
    private var checkmark:some View {
        Image(systemName: "checkmark")
            .foregroundStyle(.white)
            .font(metrics.checkmarkFont)
    }
    
    private var colorGrid: some View {
        LazyVGrid(columns: metrics.columns, spacing: 0) {
            ForEach(Color.bicolors, id: \.self) { bicolor in
                
                let isCurrentColor = (bicolor.description == bubble.color)
                
                bicolor.color
                    .frame(height: 60)
                    .overlay { if isCurrentColor { checkmark }}
                    .onTapGesture {
                        changeColor(isCurrentColor, bicolor)
                        viewModel.saveStartDelay(bubble)
                        viewModel.reset()
                    }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var colorNameLabel:some View {
        VStack {
            let colorName = String.readableName(for: bubble.color)
            
            Spacer()
            HStack {
                CounterLabel(kind: bubble.isTimer ? .timer : .stopwatch)
                Text(colorName).font(.system(size: 30))
            }
        }
        .padding(.bottom)
    }
    
    // MARK: - Methods
    private func removeDelay() {
        if bubble.delayBubble?.initialDelay != 0 {
            bubble.delayBubble?.initialDelay = 0
            viewModel.removeStartDelay()
            displayedStartDelay = 0
        }
    }
    
    private func changeColor(_ sameColor:Bool, _ bicolor:Color.Bicolor) {
        if !sameColor { //1
            viewModel.setColor(of: bubble, to: bicolor.description)
            viewModel.saveStartDelay(bubble)
        }
    } //3
}

extension MoreOptionsOverlay {
    struct Input {
        var bubble:Bubble
        var initialBubbleColor:Color
        var initialStartDelay:Int
        var userEditedDelay:Int
    }
    
    private struct Metrics {
        let digitSpacing = CGFloat(2)
        
        let delayFont = Font.displayFont
        let checkmarkFont = Font.system(size: 30, weight: .medium)
        
        var columns:[GridItem] { Array(repeating: GridItem(spacing: 0), count: 4) }
    }
}

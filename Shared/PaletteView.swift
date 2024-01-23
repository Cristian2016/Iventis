//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
// PaletteView presented either when user taps plusSymbol or swipes right from left screen edge in BubbleList
// PaletteView dismissed either when user taps a color or swipes left from right screen edge

import SwiftUI
import MyPackage

struct PaletteView: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(Secretary.self) private var secretary
    
    @State private var tappedCircle:String?
    @State private var longPressedCircle:String?
    
    private let colums = Array(repeating: GridItem(), count: 3)
    
    var body: some View {
        if secretary.showPaletteView {
            ZStack {
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea()
                
                colors
                    .gesture(swipeGesture)
                
                if let longPressedCircleColor = longPressedCircle {
                    Color.bubbleColor(forName: longPressedCircleColor)
                        .aspectRatio(1.0, contentMode: .fit)
                        .transition(.scale)
                }
                
                UserAssistOverlay()
            }
            .transition(.move(edge: .leading))
            .onChange(of: SmallHelpOverlay.Model.shared.topmostView) { oldValue, newValue in
                if newValue == .bubbleList {
                    secretary.palette(.hide)
                }
            }
        }
    }
    
    // MARK: - Legos
    private var colors:some View {
        ScrollView {
            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                ForEach(Color.paletteBicolors, id: \.self) { subarray in
                    GridRow {
                        ForEach(subarray) { bicolor in
                            VStack {
                                bicolor.color
                                Text(String.readableName(for: bicolor.description))
                            }
                            .padding(2)
                            .background()
                            .onTapGesture { createStopwatch(bicolor) }
                            .onLongPressGesture { showDurationPicker(bicolor) }
                        }
                        .font(.system(size: 14, design: .rounded))
                    }
                }
            }
            .containerRelativeFrame(.vertical)
        }
        .scrollIndicators(.hidden)
    }
    
    private var infoContent:some View {
        VStack {
            VStack(alignment: .leading) {
                Text("**Stopwatch** \(Image.tap) Tap any color")
                Text("**Timer** \(Image.longPress) Long-Press")
                Text("**Dismiss** \(Image.leftSwipe) Swipe Left")
            }
        }
    }
    
    // MARK: - Methods
    fileprivate func createStopwatch(_ bicolor:Color.Bicolor) {
        UserFeedback.singleHaptic(.light)
        
        viewModel.createBubble(.stopwatch, bicolor.description)
        withAnimation(.easeInOut(duration: 0.1)) { tappedCircle = bicolor.description }
        secretary.palette(.hide)
        tappedCircle = nil
    }
    
    fileprivate func showDurationPicker(_ bicolor:Color.Bicolor) {
        UserFeedback.singleHaptic(.medium)
        
        withAnimation(.easeInOut(duration: 0.2)) { longPressedCircle = bicolor.description }
        
        delayExecution(.now() + 0.25) {
            SmallHelpOverlay.Model.shared.topmostView(.durationPicker)
            viewModel.durationPicker.reason = .createTimer(bicolor)
            longPressedCircle = nil
        }
    }
    
    // MARK: -
    private var swipeGesture:some Gesture {
        DragGesture(minimumDistance: 1)
            .onEnded {
                if $0.translation.width < 40 {
                    secretary.palette(.hide)
                }
            }
    }
}

extension Image {
    static let tapHold = Image("taphold")
}

struct ShadowModifier:ViewModifier {
    let opacity:CGFloat
    func body(content:Content) -> some View {
        content.shadow(color: .black.opacity(opacity), radius: 4, y: 2.5)
    }
}

extension View {
    //https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
    //https://www.youtube.com/watch?v=nGENKnaSWPM
    func standardShadow(_ opacity:CGFloat = 0.12) -> some View {
        modifier(ShadowModifier(opacity: opacity))
    }
}

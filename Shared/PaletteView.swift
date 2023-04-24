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
    @EnvironmentObject private var viewModel:ViewModel
    @State private var tappedCircle:String?
    @State private var longPressedCircle:String?
    @AppStorage("showPaletteHint", store: .shared) var showPaletteInfo = true
    private let secretary = Secretary.shared
    @State private var show = false
    
    private let colums = Array(repeating: GridItem(), count: 3)
    
    private func dismiss() {
        withAnimation { showPaletteInfo = false }
        secretary.showPaletteInfo = false
    }
    
    private func moreInfo() {
        secretary.showInfoVH = true
    }
    
    var body: some View {
        ZStack {
            if show {
                ZStack {
                    colors
                    if showPaletteInfo {
                        let title = "Create Stopwatch/Timer"
                        
                        //info has content and two buttons (two actions)
                        ThinMaterialLabel(title) { infoContent }
                    action: { dismiss() } //dismiss action
                    moreInfo: { moreInfo() } //more info action
                    }
                }
                .gesture(swipeGesture)
                .transition(.move(edge: .leading))
            }
        }
        .onReceive(secretary.$showPaletteView) { output in
            withAnimation { show = output }
        }
        .onReceive(secretary.$showPaletteInfo) { output in
            if output {
                withAnimation { self.showPaletteInfo = true }
            }
        }
    }
    
    // MARK: - Legos
    private var colors:some View {
        ScrollView {
            Color
                .clear
                .frame(height: 30)
            Grid {
                ForEach(Color.paletteTriColors, id: \.self) { subarray in
                    GridRow {
                        ForEach(subarray) { tricolor in
                            Circle()
                                .fill(tricolor.sec)
                                .scaleEffect(x: scale(tricolor) , y: scale(tricolor))
                                .onTapGesture { createBubble(tricolor) }
                                .onLongPressGesture { showDurationPicker(tricolor) }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
    
    private var infoContent:some View {
        VStack {
            VStack(alignment: .leading) {
                Text("**Stopwatch** \(Image.tap) Tap any color")
                Text("**Timer** \(Image.longPress) Long Press")
                Text("**Dismiss** \(Image.swipeLeft) Swipe Left")
            }
        }
    }
            
    // MARK: - Methods
    private func scale(_ tricolor:Color.Tricolor) -> CGFloat {
        if tricolor.description == tappedCircle { return 2.8 }
        if tricolor.description == longPressedCircle { return 4 }
        return 1.8
    }
                              
    fileprivate func createBubble(_ tricolor:Color.Tricolor) {
        UserFeedback.singleHaptic(.light)
        
        viewModel.createBubble(.stopwatch, tricolor.description)
        withAnimation(.easeInOut(duration: 0.1)) { tappedCircle = tricolor.description }
        secretary.togglePaletteView()
        tappedCircle = nil
    }
    
    fileprivate func showDurationPicker(_ tricolor:Color.Tricolor) {
        UserFeedback.singleHaptic(.medium)
        
        withAnimation(.easeInOut(duration: 0.1)) { longPressedCircle = tricolor.description }
        
        delayExecution(.now() + 0.2) {
            secretary.durationPickerMode = .create(tricolor)
            longPressedCircle = nil
        }
    }
    
    // MARK: -
    private var swipeGesture:some Gesture {
        DragGesture(minimumDistance: 1)
            .onEnded { if $0.translation.width < 0 {
                secretary.togglePaletteView()
            }}
    }
}

struct PaletteView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteView()
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
    func standardShadow(_ opacity:CGFloat = 0.3) -> some View {
        modifier(ShadowModifier(opacity: opacity))
    }
}

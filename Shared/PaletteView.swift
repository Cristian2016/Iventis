//
//  PaletteView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI
import MyPackage

struct PaletteView: View {
    @AppStorage("showPaletteHint", store: .shared) private var showPaletteHint = true
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var tappedCircle:String?
    @State private var longPressedCircle:String?
    
    private let colums = Array(repeating: GridItem(), count: 3)
    
    var body: some View {
        ZStack {
            circles
            if showPaletteHint {
                ThinMaterialLabel(title: "Create Bubbles") { labelContent }
            action: { withAnimation { showPaletteHint = false } }

            }
            else { infoSymbol }
        }
        .gesture(swipeGesture)
        .offset(x: viewModel.isPaletteShowing ? 0 : -max(UIScreen.size.height, UIScreen.size.width))
    }
    
    // MARK: - Legos
    private var labelContent:some View {
        VStack {
            VStack(alignment: .leading) {
                Text("\(Image.tap) Tap Color for Stopwatch")
                Text("\(Image.longPress) Long Press for Timer")
                Text("\(Image.leftSwipe) Swipe Left to Dismiss")
            }
        }
    }
    
    private var infoSymbol:some View {
        Push(.topRight) {
            Image(systemName: "info.circle.fill")
        }
        .foregroundColor(.black)
        .padding([.trailing])
        .onTapGesture { withAnimation { showPaletteHint = true } }
    }
    
    private func scale(_ tricolor:Color.Tricolor) -> CGFloat {
        if tricolor.description == tappedCircle { return 2.8 }
        if tricolor.description == longPressedCircle { return 4 }
        return 1.8
    }
                              
    fileprivate func createBubble(_ tricolor:Color.Tricolor) {
        viewModel.createBubble(.stopwatch, tricolor.description)
        UserFeedback.singleHaptic(.light)
        
        withAnimation(.easeInOut(duration: 0.1)) {
            tappedCircle = tricolor.description
        }
        
        delayExecution(.now() + 0.2) {
            viewModel.isPaletteShowing = false //dismiss PaletteView
            tappedCircle = nil
        }
    }
    
    fileprivate func showDurationPicker(_ tricolor:Color.Tricolor) {
        UserFeedback.singleHaptic(.medium)
        
        withAnimation(.easeInOut(duration: 0.1)) {
            longPressedCircle = tricolor.description
        }
        
        delayExecution(.now() + 0.2) {
            viewModel.durationPicker_OfColor = tricolor.sec
            viewModel.isPaletteShowing = false //dismiss PaletteView
            longPressedCircle = nil
        }
    }
    
    private var circles:some View {
        let rect = Rectangle().fill(.clear)
       return ScrollView {
            rect
            rect
            LazyVGrid(columns: colums, spacing: 10) {
                ForEach(Color.bubbleTriColors, id:\.self) { tricolor in
                    Circle()
                        .fill(tricolor.sec)
                        .scaleEffect(x: scale(tricolor) , y: scale(tricolor))
                        .onTapGesture { createBubble(tricolor) }
                        .onLongPressGesture { showDurationPicker(tricolor) }
                }
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
    
    private func circle(_ color:Color.Tricolor) -> some View {
        Circle().fill(color.sec)
            
    }
    
    // MARK: -
    private var swipeGesture:some Gesture {
        DragGesture(minimumDistance: 1)
            .onEnded {
                if $0.translation.width < 0 {
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.isPaletteShowing = false
                    }
                }
            }
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

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
    @State private var offset = -UIScreen.size.height
    
    @State private var tappedCircle:String?
    @State private var longPressedCircle:String?
    
    private let colums = Array(repeating: GridItem(), count: 3)
    
    var body: some View {
        ZStack {
            circles
            if showPaletteHint {
                ThinMaterialLabel(title: "Create Bubbles") { hintLabelContent }
            action: { withAnimation { showPaletteHint = false } }

            }
            else { infoSymbol }
        }
        .offset(x: offset)
        .gesture(swipeGesture)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25)) { offset = 0 }
        }
    }
    
    // MARK: - Legos
    private var circles:some View {
        let clearColor = Color.clear
       return ScrollView {
            clearColor
            clearColor
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
    
    private var hintLabelContent:some View {
        VStack {
            VStack(alignment: .leading) {
                Text("\(Image.tap) Tap Any Color for Stopwatch")
                Text("\(Image.longPress) Long Press for Timer")
                Text("\(Image(systemName: "arrowshape.backward.fill")) Swipe Left from Right Screen Edge to Dismiss")
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
    
    private let scales = [CGFloat(1.8), 1.9, 2.0, 2.1, 2.2, 2.3]
        
    // MARK: - Methods
    private func scale(_ tricolor:Color.Tricolor) -> CGFloat {
        if tricolor.description == tappedCircle { return 2.8 }
        if tricolor.description == longPressedCircle { return 4 }
        return 1.8
    }
    
    private func dismiss() {
        delayExecution(.now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.25)) {
                offset = -UIScreen.size.width
            }
            
            delayExecution(.now() + 0.26) {
                viewModel.isPaletteShowing = false //dismiss PaletteView
                tappedCircle = nil
            }
        }
    }
                              
    fileprivate func createBubble(_ tricolor:Color.Tricolor) {
        UserFeedback.singleHaptic(.light)
        
        viewModel.createBubble(.stopwatch, tricolor.description)
        withAnimation(.easeInOut(duration: 0.1)) { tappedCircle = tricolor.description }
        dismiss()
    }
    
    fileprivate func showDurationPicker(_ tricolor:Color.Tricolor) {
        UserFeedback.singleHaptic(.medium)
        
        withAnimation(.easeInOut(duration: 0.1)) { longPressedCircle = tricolor.description }
        
        delayExecution(.now() + 0.2) {
            viewModel.durationPicker_OfColor = tricolor.sec
            longPressedCircle = nil
        }
    }
    
    // MARK: -
    private var swipeGesture:some Gesture {
        DragGesture(minimumDistance: 1)
            .onEnded { if $0.translation.width < 0 { dismiss() }}
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

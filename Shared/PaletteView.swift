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
    @Binding private var showPalette:Bool
    @State private var tappedCircle:String?
    
    let scales = [CGFloat(1.5), 1.55, 1.65, 1.75, 1.85, 1.6, 2.0, 1.9, 1.8, 1.7, 1.4, 2.1, 2.2]
    
    private let tricolors = [
        Color.Bubbles.aqua, Color.Bubbles.slateBlue, Color.Bubbles.lemon, Color.Bubbles.silver, Color.Bubbles.ultramarine, Color.Bubbles.sourCherry, Color.Bubbles.red, Color.Bubbles.sky, Color.Bubbles.bubbleGum,  Color.Bubbles.green, Color.Bubbles.charcoal, Color.Bubbles.magenta, Color.Bubbles.purple, Color.Bubbles.orange, Color.Bubbles.chocolate,
         Color.Bubbles.mint, Color.Bubbles.byzantium, Color.Bubbles.rose, Color.Bubbles.aubergine,
        Color.Bubbles.cayenne, Color.Bubbles.mocha
    ]
    
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
        .offset(x: viewModel.isPaletteShowing ? 0 : -UIScreen.size.height)
    }
    
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
    
    // MARK: - Legos
    private var labelContent:some View {
        VStack {
            VStack(alignment: .leading) {
                Text("\(Image(systemName:"hand.tap")) Tap Color for Stopwatch")
                Text("\(Image(systemName:"digitalcrown.horizontal.press")) Long Press for Timer")
                Text("\(Image(systemName:"arrow.left")) Swipe Left to Dismiss")
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
        return 1.8
    }
                              
    var circles:some View {
        let rect = Rectangle().fill(.clear)
       return ScrollView {
            rect
            rect
            LazyVGrid(columns: colums, spacing: 10) {
                ForEach(tricolors, id:\.self) { tricolor in
                    Circle()
                        .fill(tricolor.sec)
                        .scaleEffect(x: scale(tricolor) , y: scale(tricolor))
                        .onTapGesture {
                            viewModel.createBubble(.stopwatch, tricolor.description)
                            UserFeedback.singleHaptic(.light)
                            
                            withAnimation(.easeInOut(duration: 0.1)) {
                                tappedCircle = tricolor.description
                            }
                            
                            delayExecution(.now() + 0.2) {
                                showPalette = false
                                tappedCircle = nil
                            }
                        }
                        .onLongPressGesture { viewModel.durationPicker_OfColor = tricolor.sec }
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
    init(_ showPalette:Binding<Bool>) {
        _showPalette = .init(projectedValue: showPalette)
    }
}

struct PaletteView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteView(.constant(true))
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

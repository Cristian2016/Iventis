//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.07.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsView1: View {
    //set within .onReceive closure. all the information MoreOptionView needs :)
    @State private var input:Input?
    private let secretary = Secretary.shared
    
    @Environment(NewViewModel.self) private var model
        
    var body: some View {
        ZStack {
            if let bubble = model.moreOptionsBubble {
                ZStack {
                    Rectangle()
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture { dismiss() }
                    
                    ViewThatFits {
                        PortraitView()
                        LandscapeView()
                    }
                    .onTapGesture { dismiss() }
                }
            }
        }
    }
    
    private var swipe:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { _ in
                UserFeedback.doubleHaptic(.heavy)
                model.removeStartDelay()
            }
    }
    
    private func saveStartDelay() {
        model.setStartDelay()
        dismiss()
    }
    
    private func dismiss() {
        model.moreOptionsBubble = nil
    }
}

extension MoreOptionsView1 {
    struct Input {
        var bubble:Bubble
        var initialBubbleColor:Color
        var initialStartDelay:Int
        var userEditedDelay:Int
    }
    
    struct Metrics {
        let radius = CGFloat(10)
        
        let minWidth = CGFloat(300)
        let digitSpacing = CGFloat(1)
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
    
    struct DisplayView1: View {
        var body: some View {
            Text("Pula mea")
        }
    }
    
    struct PortraitView:View {
        @Environment(NewViewModel.self) private var model
        
        var body: some View {
            if let bubble = model.moreOptionsBubble {
                ZStack {
                    VStack {
                        Color.background
                            .frame(height: 200)
                            .overlay {
                                
                            }
                        
                        UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                            .fill(.white)
                            .overlay {
                                ColorsGrid(bubble) {
                                    
                                }
                            }
                            .frame(minHeight: 400)
                    }
                    .padding()
                }
            }
        }
    }

    struct LandscapeView:View {
        var body: some View {
            ZStack {
                Rectangle()
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                
                HStack(alignment: .top) {
                    Rectangle()
                        .fill(.white)
                        .frame(height: 200)
                        .frame(minWidth: 300)

                    UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                        .fill(.white)
                        .overlay {
                            ScrollView {
                                Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                                    ForEach(Color.paletteTriColors, id: \.self) { tricolors in
                                        GridRow {
                                            ForEach(tricolors) { tricolor in
                                                tricolor.sec
                                                    .aspectRatio(1.8, contentMode: .fit)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(8)
                            .scrollIndicators(.hidden)
                        }
                }
                .padding()
            }
        }
    }
}

#Preview {
    MoreOptionsView1()
}

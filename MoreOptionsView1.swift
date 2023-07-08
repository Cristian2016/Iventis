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
    
    var body: some View {
        ZStack {
            if let emptyStruct = input {
                ViewThatFits {
                    PortraitView()
                    LandscapeView()
                }
            }
        }
        .onReceive(secretary.$moreOptionsBuble) {
            if let bubble = $0 {
                let color = Color.bubbleColor(forName: bubble.color)
                let initialStartDelay = Int(bubble.startDelayBubble?.initialClock ?? 0)
                                                
                input = Input(bubble: bubble,
                              initialBubbleColor: color,
                              initialStartDelay: initialStartDelay,
                              userEditedDelay: initialStartDelay)
                
            } else { input = nil }
        }
    }
}

extension MoreOptionsView1 {
    struct Input {
        var bubble:Bubble
        var initialBubbleColor:Color
        var initialStartDelay:Int
        var userEditedDelay:Int
    }
    
    struct PortraitView:View {
        var body: some View {
            ZStack {
                Rectangle()
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack {
                    Rectangle()
                        .fill(.white)
                        .frame(height: 200)
                    
                    UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                        .fill(.white)
                        .overlay {
                            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                                ForEach(Color.paletteTriColors, id: \.self) { tricolors in
                                    GridRow {
                                        ForEach(tricolors) { tricolor in
                                            tricolor.sec
                                        }
                                    }
                                }
                            }
                            .padding(8)
                        }
                        .frame(minHeight: 400)
                }
                .padding()
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

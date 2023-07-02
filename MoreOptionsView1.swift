//
//  what.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.07.2023.
//

import SwiftUI
import MyPackage

struct SomeView: View {
    var body: some View {
        ViewThatFits {
            PortraitView()
            LandscapeView()
        }
        
    }
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
                                                .aspectRatio(2.0, contentMode: .fit)
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

#Preview {
    SomeView()
}

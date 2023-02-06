//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsView1: View {
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            ZStack {
                Rectangle().fill(.thinMaterial)
                    .ignoresSafeArea()
                VStack {
                    Color.white.cornerRadius(20)
                        .standardShadow()
                        .overlay {
                            VStack {
                                Rectangle()
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: 4) {
                                        ForEach(Color.triColors) { triColor in
                                            ZStack {
                                                Circle()
                                                triColor.sec
                                            }
                                            .aspectRatio(isLandscape ? 4/1 : 2/1, contentMode: .fit)
                                        }
                                    }
                                }
                                .scrollIndicators(.hidden)
                            }
                            .padding()
                        }
                    Text("Swipe Left to Dismiss")
                }
                    .padding()
                    
            }
        }
    }
    
    // MARK: - Lego
    
    
    // MARK: -
    private let columns = Array(repeating: GridItem(), count: 3)
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsView1()
    }
}

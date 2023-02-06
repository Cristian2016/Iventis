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
            ZStack {
                Rectangle()
                    .fill(.green)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            colors
                            Text("\(Image.swipeLeft) Swipe Left to Save")
                        }
                    }
                    .padding()
            }
        }
    }
    
    // MARK: - Lego
    private var colors:some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(Color.triColors) { tricolor in
                    tricolor.sec
                }
            }
        }
        .frame(height: 120)
    }
    
    // MARK: -
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsView1()
    }
}

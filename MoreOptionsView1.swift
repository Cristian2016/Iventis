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
        
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack {
                Color.white
                    .cornerRadius(30)
                    .padding()
                    .overlay {
                        colors
                    }
                Text("\(Image.swipeLeft) Swipe Left to Save")
            }
        }
    }
    
    // MARK: - Lego
    private var colors:some View {
        LazyVGrid(columns: columns) {
            ForEach(Color.triColors, id: \.self) { tricolor in
                Circle().fill(tricolor.sec)
            }
        }
    }
    
    // MARK: -
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsView1()
    }
}

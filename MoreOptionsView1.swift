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
                colors.cornerRadius(30)
                Text("\(Image.swipeLeft) Swipe Left to Save")
            }
            .padding()
        }
    }
    
    // MARK: - Lego
    private var colors:some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(Color.triColors, id: \.self) { tricolor in
                    Circle()
                        .fill(tricolor.sec)
                        .scaleEffect(x: 1.6, y: 1.6)
                }
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

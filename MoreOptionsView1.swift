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
                .fill(.green)
                .ignoresSafeArea()
            
            VStack {
                Color.white
                    .cornerRadius(30)
                    .padding()
                Text("\(Image.swipeLeft) Swipe Left ")
            }
        }
    }
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsView1()
    }
}

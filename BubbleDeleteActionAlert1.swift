//
//  BubbleDeleteActionAlert1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.04.2023.
//

import SwiftUI
import MyPackage

struct BubbleDeleteActionAlert1: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(.blue)
            Circle()
                .fill(.blue)
                .frame(height: 100)
                .offset(x: -40, y: -40)
        }
        .compositingGroup()
        .aspectRatio(0.8, contentMode: .fit)
        .frame(height: 300)
        .standardShadow()
    }
}

struct BubbleDeleteActionAlert1_Previews: PreviewProvider {
    static var previews: some View {
        BubbleDeleteActionAlert1()
    }
}

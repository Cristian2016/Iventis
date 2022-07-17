//
//  SwiftUIView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct TapHold: View {
    let ratio = CGFloat(1.66)
    let fontSize: CGFloat
    
    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: fontSize * ratio))
            VStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.green)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TapHold(fontSize: 60)
    }
}

//
//  SwiftUIView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct TapHold: View {
    var body: some View {
        let width = UIScreen.main.bounds.width
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: width * 0.2))
            Image(systemName: "clock.fill")
                .font(.system(size: width * 0.12))
                .foregroundColor(.white)
                .offset(x: 0, y: -11)
        }
        .foregroundColor(.green)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TapHold()
    }
}

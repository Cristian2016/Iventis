//
//  SwiftUIView.swift
//  Timers
//
//  Created by Cristian Lapusan on 17.04.2022.
//

import SwiftUI

struct TapHold: View {
    var body: some View {
        VStack {
            Label {
                VStack {
                    Text("Timer")
                    Text("Tap & Hold")
                }
                
            } icon: {
                Image.tapHold
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .font(.largeTitle)
        .padding()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TapHold()
    }
}

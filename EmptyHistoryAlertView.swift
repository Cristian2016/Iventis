//
//  EmptyHistoryAlertView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct EmptyHistoryAlertView: View {
    var body: some View {
        VStack (alignment:.leading) {
            ZStack {
                Image("secondsImage")
                    .resizable()
                    .frame(width: 130, height: 130)
                Image(systemName: "circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .offset(x: -30, y: -30)
            }
            VStack (alignment:.leading) {
                Text("History Empty")
                    .font(.title)
                Text("Tap Seconds\nto Start")
                    .foregroundColor(.secondary)
                    .font(.system(.title3, design: .monospaced))
            }
        }
        .padding()
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.background)
                .standardShadow()
        }
    }
}

struct EmptyHistoryAlertView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyHistoryAlertView()
    }
}

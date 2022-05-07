//
//  EmptyHistoryAlertView.swift
//  Timers
//
//  Created by Cristian Lapusan on 07.05.2022.
//

import SwiftUI

struct EmptyHistoryAlertView: View {
    var body: some View {
        VStack {
            Image(systemName: "0.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
            VStack (alignment:.leading) {
                Text("History Empty")
                    .font(.largeTitle)
                Text("Tap Seconds Button\nto Start")
                    .foregroundColor(.secondary)
                    .font(.system(.title2, design: .monospaced))
            }
            
        }
        .padding()
    }
}

struct EmptyHistoryAlertView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyHistoryAlertView()
    }
}

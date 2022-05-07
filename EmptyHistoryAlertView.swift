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
            ZStack {
                Image(systemName: "circle")
                    .font(.system(size: 150, weight: .ultraLight, design: .default))
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.lightGray)
                    .overlay {
                        Push(.bottomRight) {
                            Image(systemName: "00.circle.fill")
                                .font(.system(size: 50, weight: .light, design: .default))
                                .foregroundColor(.secondary)
                        }
                        .padding(6)
                    }
                Image(systemName: "circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
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
    }
}

struct EmptyHistoryAlertView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyHistoryAlertView()
    }
}

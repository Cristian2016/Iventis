//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct SpotlightAlert: View {
    var body: some View {
        VStack {
//            Text("Bubble Detail")
//                .font(.title3)
            Image.spotlight
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
            Text("Tap Minutes to dismiss")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct SpotlightAlert_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightAlert()
    }
}

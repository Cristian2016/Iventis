//
//  AdaptiveView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 15.03.2023.
//

import SwiftUI

struct AdaptiveView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .aspectRatio(2.5, contentMode: .fit)
            .overlay {
                Text("Done")
                    .font(.system(size: 300))
                    .minimumScaleFactor(0.1)
                    .foregroundColor(.white)
                    .padding([.leading, .trailing])
            }
            .padding()
    }
}

struct AdaptiveView_Previews: PreviewProvider {
    static var previews: some View {
        AdaptiveView()
    }
}

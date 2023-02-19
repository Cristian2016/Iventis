//
//  GradientView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.02.2023.
//

import SwiftUI

struct GradientView: View {
    let color:Color
    
    var body: some View {
        VStack {
            Circle()
                .overlay {
                    LinearGradient(stops: [.init(color: .red, location: 200), .init(color: .blue, location: 400)], startPoint: .trailing, endPoint: .bottom)
                }
                .clipShape(Circle())
            Circle()
                .fill(color.gradient)
        }
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView(color: .red)
    }
}

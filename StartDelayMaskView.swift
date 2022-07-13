//
//  DelayStartMaskView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//

import SwiftUI

struct StartDelayMaskView: View {
    var body: some View {
        HStack (spacing: StartDelayMaskView.metrics.spacing) {
            Circle().hidden()
            Circle().hidden()
            Circle()
                .overlay {
                    Push(.bottomRight) {
                        hundredthsCircle
                    }
                }
        }
        .foregroundColor(.green)
    }
    
    static var metrics = Metrics()
    
    private var hundredthsCircle:some View {
        Circle()
            .fill(Color.red)
            .frame(width: 50, height: 50)
            .offset(x:4, y:4)
    }
    
    struct Metrics {
        var circleDiameter:CGFloat = {
            if UIDevice.isIPad {
                return 140
            } else {
               return CGFloat(UIScreen.main.bounds.size.width / 2.7)
            }
        }()
        let fontRatio = CGFloat(0.42)
        let spacingRatio = CGFloat(-0.28)
        
        lazy var spacing = circleDiameter * spacingRatio
        lazy var fontSize = circleDiameter * fontRatio
        lazy var hundredthsFontSize = circleDiameter / 6
        
        lazy var hundredthsInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

struct DelayStartMaskView_Previews: PreviewProvider {
    static var previews: some View {
        StartDelayMaskView()
    }
}

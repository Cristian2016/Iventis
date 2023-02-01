//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI

struct DeleteActionAlert: View {
    
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            Image("aaa")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(x: 0.7, y: 0.7)
            RoundedRectangle(cornerRadius: metrics.radius)
                .fill(.green)
                .opacity(0.6)
                .frame(width: metrics.width, height: metrics.height)
        }
        
    }
    
    struct Metrics {
        let ratio = CGFloat(0.878)
        let width = CGFloat(256)
        var height:CGFloat { width / ratio }
        let radius = CGFloat(52)
    }
}

struct DeleteActionAlert_Previews: PreviewProvider {
    static var previews: some View {
        DeleteActionAlert()
    }
}

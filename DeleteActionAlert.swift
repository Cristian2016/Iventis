//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI


struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct DeleteActionAlert: View {
    
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            //            Image("aaa")
            //                .resizable()
            //                .aspectRatio(contentMode: .fit)
            //                .scaleEffect(x: 0.6, y: 0.6)
            RoundedRectangle(cornerRadius: metrics.radius)
                .fill(metrics.backgroundColor)
                .frame(width: metrics.width, height: metrics.height)
            //                .opacity(0.0)
                .standardShadow()
                .overlay(
                    VStack {
                       
                    }
                )
        }
    }
    
    struct Metrics {
        let ratio = CGFloat(0.878)
        let width = CGFloat(220)
        var height:CGFloat { width / ratio }
        let radius = CGFloat(52)
        let backgroundColor = Color("deleteActionAlert")
    }
}

struct DeleteActionAlert_Previews: PreviewProvider {
    static var previews: some View {
        DeleteActionAlert()
    }
}

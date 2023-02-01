//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI
import MyPackage


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
            RoundedRectangle(cornerRadius: metrics.radius)
                .fill(metrics.backgroundColor)
                .frame(width: metrics.width, height: metrics.height)
                .standardShadow()
                .overlay(
                    Push(.bottomMiddle) {
                        VStack(spacing: 4) {
                            RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
                                .fill(.red)
                                .frame(width: 204, height: 80)
                                .overlay {
                                    Text("Bubble")
                                        .font(.system(size: 36, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
                                .fill(.red)
                                .frame(width: 204, height: 80)
                                .overlay {
                                    Text("Session")
                                        .font(.system(size: 36, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                        }
                    }
                        .padding([.bottom], 18)
                )
                .overlay {
                    Push(.topMiddle) {
                        Text("\(Image.trash) Delete")
                            .foregroundColor(.red)
                            .font(.system(size: 28, weight: .medium))
                    }
                    .padding([.top])
                    .padding([.top], 6)
                }
        }
    }
    
    struct Metrics {
        let ratio = CGFloat(0.878)
        let width = CGFloat(220)
        var height:CGFloat { width / ratio }
        let radius = CGFloat(40)
        let backgroundColor = Color("deleteActionAlert")
    }
}

struct DeleteActionAlert_Previews: PreviewProvider {
    static var previews: some View {
        DeleteActionAlert()
    }
}

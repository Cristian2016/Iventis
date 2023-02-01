//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI

extension UIBezierPath {
    struct DeleteActionAlert {
        static func buttonPath(_ frame:CGRect) -> UIBezierPath {
            let bezierPath = UIBezierPath()
                bezierPath.move(to: CGPoint(x: frame.minX + 0.99163 * frame.width, y: frame.minY + 0.2))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.99211 * frame.width, y: frame.minY + 0.22))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99906 * frame.width, y: frame.minY + 1.89), controlPoint1: CGPoint(x: frame.minX + 0.99534 * frame.width, y: frame.minY + 0.51), controlPoint2: CGPoint(x: frame.minX + 0.99789 * frame.width, y: frame.minY + 1.12))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 4.59), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 2.61), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 3.27))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 54.41))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99995 * frame.width, y: frame.minY + 55.71), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 54.94), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 55.36))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 61.8), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 57.57), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 59.58))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 63.2))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99236 * frame.width, y: frame.minY + 87.24), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 75.52), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 81.68))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.99126 * frame.width, y: frame.minY + 88.32))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.92633 * frame.width, y: frame.minY + 103.9), controlPoint1: CGPoint(x: frame.minX + 0.98028 * frame.width, y: frame.minY + 95.56), controlPoint2: CGPoint(x: frame.minX + 0.95650 * frame.width, y: frame.minY + 101.27))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.82166 * frame.width, y: frame.minY + 106), controlPoint1: CGPoint(x: frame.minX + 0.89869 * frame.width, y: frame.minY + 106), controlPoint2: CGPoint(x: frame.minX + 0.87301 * frame.width, y: frame.minY + 106))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.17834 * frame.width, y: frame.minY + 106))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.07816 * frame.width, y: frame.minY + 104.17), controlPoint1: CGPoint(x: frame.minX + 0.12699 * frame.width, y: frame.minY + 106), controlPoint2: CGPoint(x: frame.minX + 0.10131 * frame.width, y: frame.minY + 106))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.07367 * frame.width, y: frame.minY + 103.9))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00874 * frame.width, y: frame.minY + 88.32), controlPoint1: CGPoint(x: frame.minX + 0.04350 * frame.width, y: frame.minY + 101.27), controlPoint2: CGPoint(x: frame.minX + 0.01972 * frame.width, y: frame.minY + 95.56))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 63.2), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 81.68), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 75.52))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 61.8))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00005 * frame.width, y: frame.minY + 55.64), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 59.55), controlPoint2: CGPoint(x: frame.minX + -0.00000 * frame.width, y: frame.minY + 57.51))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 54.41), controlPoint1: CGPoint(x: frame.minX + -0.00000 * frame.width, y: frame.minY + 55.29), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 54.9))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 4.59))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00082 * frame.width, y: frame.minY + 2.01), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 3.27), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 2.61))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.00094 * frame.width, y: frame.minY + 1.89))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00789 * frame.width, y: frame.minY + 0.22), controlPoint1: CGPoint(x: frame.minX + 0.00211 * frame.width, y: frame.minY + 1.12), controlPoint2: CGPoint(x: frame.minX + 0.00466 * frame.width, y: frame.minY + 0.51))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.01911 * frame.width, y: frame.minY), controlPoint1: CGPoint(x: frame.minX + 0.01086 * frame.width, y: frame.minY), controlPoint2: CGPoint(x: frame.minX + 0.01361 * frame.width, y: frame.minY))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 0.98089 * frame.width, y: frame.minY))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99163 * frame.width, y: frame.minY + 0.2), controlPoint1: CGPoint(x: frame.minX + 0.98639 * frame.width, y: frame.minY), controlPoint2: CGPoint(x: frame.minX + 0.98914 * frame.width, y: frame.minY))
                bezierPath.close()
                bezierPath.fill()

            return bezierPath
        }
    }
}

struct ButtonShape:Shape {
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath.DeleteActionAlert.buttonPath(rect).cgPath)
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
                .overlay(ButtonShape().foregroundColor(.red))
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

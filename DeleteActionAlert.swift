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
                //// Color Declarations
                let color = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.000)

                //// Bezier Drawing
                let bezierPath = UIBezierPath()
                bezierPath.move(to: CGPoint(x: frame.minX + 97, y: frame.minY + 0))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 97, y: frame.minY + 22.34), controlPoint1: CGPoint(x: frame.minX + 97, y: frame.minY + 0.04), controlPoint2: CGPoint(x: frame.minX + 97, y: frame.minY + 22.34))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 97, y: frame.minY + 23), controlPoint1: CGPoint(x: frame.minX + 97, y: frame.minY + 22.62), controlPoint2: CGPoint(x: frame.minX + 97, y: frame.minY + 22.84))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 97, y: frame.minY + 23.5), controlPoint1: CGPoint(x: frame.minX + 97, y: frame.minY + 23.5), controlPoint2: CGPoint(x: frame.minX + 97, y: frame.minY + 23.5))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 97, y: frame.minY + 24.67))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 82.6, y: frame.minY + 45.24), controlPoint1: CGPoint(x: frame.minX + 97, y: frame.minY + 33.88), controlPoint2: CGPoint(x: frame.minX + 91.25, y: frame.minY + 42.09))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 61.52, y: frame.minY + 47), controlPoint1: CGPoint(x: frame.minX + 77.03, y: frame.minY + 47), controlPoint2: CGPoint(x: frame.minX + 71.86, y: frame.minY + 47))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 42.8, y: frame.minY + 47))
                bezierPath.addCurve(to: CGPoint(x: frame.minX + 15.3, y: frame.minY + 45.46), controlPoint1: CGPoint(x: frame.minX + 25.14, y: frame.minY + 47), controlPoint2: CGPoint(x: frame.minX + 19.97, y: frame.minY + 47))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 14.4, y: frame.minY + 45.24))
                bezierPath.addCurve(to: CGPoint(x: frame.minX, y: frame.minY + 24.67), controlPoint1: CGPoint(x: frame.minX + 5.75, y: frame.minY + 42.09), controlPoint2: CGPoint(x: frame.minX, y: frame.minY + 33.88))
                bezierPath.addCurve(to: CGPoint(x: frame.minX, y: frame.minY + 23.5), controlPoint1: CGPoint(x: frame.minX, y: frame.minY + 23.5), controlPoint2: CGPoint(x: frame.minX, y: frame.minY + 23.5))
                bezierPath.addCurve(to: CGPoint(x: frame.minX, y: frame.minY + 23.02), controlPoint1: CGPoint(x: frame.minX, y: frame.minY + 23.47), controlPoint2: CGPoint(x: frame.minX, y: frame.minY + 23.02))
                bezierPath.addCurve(to: CGPoint(x: frame.minX, y: frame.minY + 22.32), controlPoint1: CGPoint(x: frame.minX, y: frame.minY + 23), controlPoint2: CGPoint(x: frame.minX, y: frame.minY + 22.76))
                bezierPath.addCurve(to: CGPoint(x: frame.minX, y: frame.minY), controlPoint1: CGPoint(x: frame.minX, y: frame.minY + 18.53), controlPoint2: CGPoint(x: frame.minX, y: frame.minY))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 97, y: frame.minY))
                bezierPath.addLine(to: CGPoint(x: frame.minX + 97, y: frame.minY + 0))
                bezierPath.close()
                color.setFill()
                bezierPath.fill()
            
            return bezierPath
        }
    }
}

//struct ButtonShape:Shape {
//    func path(in rect: CGRect) -> Path {
//
//    }
//}

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
                .overlay {
                    
                }
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

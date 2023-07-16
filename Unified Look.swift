//
//  Unified Look.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.12.2023.
//

import SwiftUI

//MARK: - Unified Look
//the entire app must have a unified look, ex: opacity for overlays should be the same, font should be consistent and so on
extension Double {
    struct Opacity {
        static let overlay = 0.25
        
        ///it lets the user interact with the transparent view
        static let basicallyTransparent = 0.001
        static let opaque = 1.0
    }
}

extension CGFloat {
    struct Overlay {
        static let scrollViewHeight = CGFloat(500.0)
        static let displayHeight = CGFloat(90.0)
    }
}

extension Font {
    static let displayFont = Font.system(size: 65, design: .rounded)
    static let digitFont = Font.system(size: 33, design: .rounded)
}

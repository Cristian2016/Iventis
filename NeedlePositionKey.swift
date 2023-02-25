//
//  NeedlePositionKey.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.02.2023.
//

import SwiftUI

struct NeedlePositionKey : EnvironmentKey {
    static var defaultValue:Binding<Int> = .constant(-1)
}

extension EnvironmentValues {
    public var needlePosition: Binding<Int> {
        get { self[NeedlePositionKey.self] }
        set { self[NeedlePositionKey.self] = newValue }
    }
}

extension View {
    func needlePosition(_ value:Binding<Int>) -> some View {
        self.environment(\.needlePosition, value)
    }
}

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

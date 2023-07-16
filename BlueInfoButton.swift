//
//  BlueInfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.03.2023.
//
import SwiftUI
import MyPackage

extension View {
    func forceMultipleLines() -> some View {
        self.fixedSize(horizontal: false, vertical: true)
    }
}

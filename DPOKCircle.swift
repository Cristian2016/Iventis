//
//  DPOKCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.03.2023.
//1 sets timer duration and dismisses DPV

import SwiftUI

extension DurationPickerView {
    struct DPOKCircle: View {
        let manager = DurationPickerView.Manager.shared
        @State private var show = false
        let action:() -> () //1
        
        var body: some View {
            ZStack {
                if show {
                    Image.roundCheckmark
                        .font(.system(size: 200, weight: .ultraLight))
                        .foregroundColor(.green)
                        .onTapGesture { action() } //1
                }
            }
            .padding()
            .onReceive(manager.$digits) {handle($0) }
        }
        
        private func handle(_ digits:[Int]) {
            let condition = digits.count == 6 || digits == [4,8]
            show = condition
        }
    }
}

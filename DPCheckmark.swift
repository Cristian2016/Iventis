//
//  DPCheckmark.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import SwiftUI

struct DPCheckmark: View {
    let manager = DurationPickerView.Manager.shared
    @State private var isVisible = false
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 18))
            .foregroundColor(.green)
            .padding(4)
            .padding([.trailing])
            .opacity(isVisible ? 1 : 0)
            .onReceive(manager.$digits) { output in
                guard !output.isEmpty else {
                    if isVisible { isVisible = false }
                    return
                }
                let condition = output.count%2 == 0 && output.reduce(0) { $0 + $1 } != 0
                isVisible = condition ? true : false
            }
    }
}

struct DPCheckmark_Previews: PreviewProvider {
    static var previews: some View {
        DPCheckmark()
    }
}

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
        HStack(spacing: 0) {
            Image.checkmark
                .foregroundColor(.green)
                .fontWeight(.bold)
            Text("**Save** \(Image.tap) Tap")
                .foregroundColor(.secondary)
        }
        .font(.system(size: 18))
        .opacity(isVisible ? 1 : 0)
        .onReceive(manager.$digits) { output in
            guard !output.isEmpty else {
                if isVisible { isVisible = false }
                return
            }
            
            let sum = output.reduce(0) { $0 + $1 }
            let condition = output.count%2 == 0 && sum != 0
            isVisible = condition ? true : false
        }
    }
}

struct DPCheckmark_Previews: PreviewProvider {
    static var previews: some View {
        DPCheckmark()
    }
}

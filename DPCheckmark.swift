//
//  DPCheckmark.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.03.2023.
//

import SwiftUI

struct DPCheckmark: View {
    let manager = DurationPickerView.Manager.shared
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 18))
            }
        }
        .onReceive(manager.$isDurationValid) { show = $0 ? true : false }
    }
}

struct DPCheckmark_Previews: PreviewProvider {
    static var previews: some View {
        DPCheckmark()
    }
}

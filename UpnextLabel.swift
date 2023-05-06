//
//  UpnextLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.05.2023.
//

import SwiftUI

struct UpnextLabel: View {
        
    var body: some View {
        HStack {
            Label("Up Next", systemImage: "arrowtriangle.right.fill")
                .foregroundColor(.white)
                .font(.system(size: 16).weight(.medium))
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.secondary)
                }
                .labelStyle(.iconOnly)
            Label("Timer", systemImage: "timer")
                .font(.system(size: 18).weight(.medium))
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(.quaternary)
        }
    }
}

struct UpnextLabel_Previews: PreviewProvider {
    static var previews: some View {
        UpnextLabel()
    }
}

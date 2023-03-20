//
//  MoreInfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.03.2023.
//

import SwiftUI

struct BlueInfoButton: View {
    var body: some View {
        Button {
            showInfo()
        } label: {
            Image(systemName: "info.square.fill")
                .font(.system(size: 80, weight: .light))
                .symbolRenderingMode(.hierarchical)
//                .foregroundColor(.black)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
    }
    
    private func showInfo() {
        switch Secretary.shared.topMostView {
            case .bubble: print("bubble info")
            case .deleteActionView: print("deleteActionView info")
            case .durationPicker: print("durationPicker info")
            case .moreOptionsView: print("moreOptionsView info")
            case .none: print("none info")
            case .palette: print("palette info")
            case .sessionDeleteActionView: print("sessionDeleteActionView info")
        }
    }
}

struct BlueInfoButton_Previews: PreviewProvider {
    static var previews: some View {
        BlueInfoButton()
    }
}

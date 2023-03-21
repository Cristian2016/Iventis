//
//  MoreInfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.03.2023.
//

import SwiftUI
import MyPackage

struct BlueInfoButton: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            if true {
                Push(.topLeft) {
                    Button {
                        showInfo()
                        Secretary.shared.showBlueInfoButton = false
                    } label: {
                        Image(systemName: "info.square.fill")
                            .font(.system(size: 80, weight: .light))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
        }
        .onReceive(Secretary.shared.$showBlueInfoButton) { output in
            withAnimation {
                show = output ? true : false
            }
        }
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

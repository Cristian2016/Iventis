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
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        ZStack {
            if show {
                Push(.topLeft) {
                    Button {
                        showInfo()
                        Secretary.shared.showBlueInfoButton = false
                    } label: {
                        Image(systemName: "info.square.fill")
                            .font(.system(size: 80, weight: .light))
                            .symbolRenderingMode(.hierarchical)
                            .padding([.leading, .trailing], 10)
                            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 15))
                    }
                }
                .tint(scheme == .dark ? .yellow : .blue)
                .padding([.leading], 4)
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
            case .moreOptionsView:
                Secretary.shared.showMoreOptionsHint = true
            case .palette:
                Secretary.shared.showPaletteInfo = true
            case .sessionDeleteActionView:
                Secretary.shared.showSessionDeleteInfo = true
        }
    }
}

struct BlueInfoButton_Previews: PreviewProvider {
    static var previews: some View {
        BlueInfoButton()
    }
}

struct SessionDeleteInfoView:View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                ThinMaterialLabel(title: "Delete Session") {
                    content
                } action: {
                    withAnimation {
                        Secretary.shared.showSessionDeleteInfo = false
                    }
                }
            }
        }
        .onReceive(Secretary.shared.$showSessionDeleteInfo) { output in
            withAnimation { show = output }
        }
    }
    
    // MARK: - Lego
    private var content:some View {
        VStack(alignment: .leading) {
            Text("*Removes Session and any*")
                .foregroundColor(.secondary)
            Text("*associated Calendar Event*")
                .foregroundColor(.secondary)
            Divider().frame(maxWidth: 300)
            Text("**Delete** \(Image.tap) Tap")
            Text("**Cancel** \(Image.tap) Tap Outside Shape")
        }
        .font(.system(size: 24))
    }
}

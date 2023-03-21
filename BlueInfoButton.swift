//
//  BlueInfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.03.2023.
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
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.ultraThickMaterial)
                                    .standardShadow()
                            }
                    }
                }
                .transition(.slide)
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
            case .durationPicker:
                Secretary.shared.showDurationPickerInfo = true
            case .moreOptionsView:
                Secretary.shared.showMoreOptionsInfo = true
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
            VStack { //to place it in the middle
                Text("*Also removes any associated Calendar Event*")
                    .fixedSize(horizontal: false, vertical: true) //⚠️
            }
            .foregroundColor(.secondary)
            
            Divider().frame(maxWidth: 300)
            Text("**Delete** \(Image.tap) Tap")
            Text("**Cancel** \(Image.tap) Tap Outside Shape")
        }
        .font(.system(size: 20))
    }
}

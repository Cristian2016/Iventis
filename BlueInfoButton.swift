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
                let title = "Delete Session"
                let subtitle = "Any associated Calendar Event will also be removed"
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                ThinMaterialLabel(title, subtitle) { infoContent } action: { dismiss() }
            }
        }
        .onReceive(Secretary.shared.$showSessionDeleteInfo) { output in
            withAnimation { show = output }
        }
    }
    
    // MARK: - Lego
    private var infoContent:some View {
        HStack(alignment: .top) {
            Image("SessionDelete")
                .thumbnail(140)
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading) {
                    Text("**Delete** \(Image.tap) Tap")
                    Text("*Yellow Button*")
                        .foregroundColor(.secondary)
                }
                VStack(alignment: .leading) {
                    Text("**Dismiss** \(Image.tap) Tap")
                    Text("*Outside Shape*")
                        .foregroundColor(.secondary)
                }
            }
        }
        .font(.system(size: 20))
    }
    
    // MARK: -
    private func dismiss() {
        withAnimation {
            Secretary.shared.showSessionDeleteInfo = false
        }
    }
}

extension View {
    func forceMultipleLines() -> some View {
        self.fixedSize(horizontal: false, vertical: true)
    }
}

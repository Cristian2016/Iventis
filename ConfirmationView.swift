//
//  ConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.09.2022.
//

import SwiftUI

struct ConfirmationView: View {
    // MARK: - Dependency
    @EnvironmentObject var viewModel:ViewModel
    
    // MARK: - Content
    var extraText:String? = nil
    var titleSymbol:String? = nil
    let title:String
    let lowerSymbol:LowerSymbol
    var fillColor:Color {
        switch lowerSymbol {
            case .on, .done: return .green
            case .off, .failed: return .red
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
            VStack {
                VStack(spacing: 0) {
                    if extraText != nil {
                        Text(extraText ?? "")
                            .font(.system(size: 50).weight(.medium))
                    }
                    HStack {
                        Image(systemName: titleSymbol ?? "")
                        Text(title)
                    }
                    .font(.system(size: 30).weight(.medium))
                }
                Divider()
                    .frame(width: 200)
                lowerSymbolView
                    .font(.system(size: 30).weight(.semibold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(fillColor)
                    .standardShadow(true)
            )
        }
        .foregroundColor(.white)
    }
    
    // MARK: - Lego
    @ViewBuilder
    var lowerSymbolView:some View {
        switch lowerSymbol {
            case .on: Label("ON", systemImage: "checkmark")
            case .off: Label("OFF", systemImage: "xmark")
            case .done: Label("Done", systemImage: "checkmark")
            case .failed: Label("Failed", systemImage: "xmark")
        }
    }
    
    // MARK: -
    enum LowerSymbol {
        case on
        case off
        case done
        case failed
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(extraText: "80s",
                         titleSymbol: Alert.alwaysOnDisplay.titleSymbol,
                         title: Alert.alwaysOnDisplay.title,
                         lowerSymbol: .done
        )
        
    }}

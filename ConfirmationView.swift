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
    let titleSymbol:String?
    let title:String
    var isOn:Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
            VStack {
                if extraText != nil {
                    Text(extraText ?? "")
                        .font(.system(size: 50).weight(.medium))
                }
                HStack {
                    Image(systemName: titleSymbol ?? "")
                    Text(title)
                }
                .font(.system(size: 30).weight(.medium))
                Divider()
                    .frame(width: 200)
                Label(isOn ? "ON" : "OFF", systemImage: isOn ? "checkmark" : "xmark")
                    .font(.system(size: 30).weight(.semibold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isOn ? Color.green : .red)
                    .standardShadow(true)
            )
        }
        .foregroundColor(.white)
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(titleSymbol: Alert.alwaysOnDisplay.titleSymbol,
                         title: Alert.alwaysOnDisplay.title, isOn: true
        )
    }
}

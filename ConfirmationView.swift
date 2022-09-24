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
    let titleSymbol:String?
    let title:String
    
    // MARK: - Internal
    var isOn:Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
            VStack {
                Image(systemName: isOn ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isOn ? .green : .red)
                HStack {
                    Image(systemName: titleSymbol ?? "")
                    Text(title)
                }
                .font(.system(size: 26).weight(.medium))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.background2)
                    .standardShadow(true)
            )
        }
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(titleSymbol: Alert.alwaysOnDisplay.titleSymbol,
                         title: Alert.alwaysOnDisplay.title, isOn: true
        )
    }
}

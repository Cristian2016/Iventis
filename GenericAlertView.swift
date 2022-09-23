//
//  GenericAlertView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.09.2022.
//

import SwiftUI

struct AlertContent {
    let symbol:String
    let titleSymbol:String?
    let title:String
    let content:String
    
    let symbolSize:CGFloat = 50
    let backgroundOpacity:CGFloat = 0.9
}

struct Alert {
    static let alwaysOnDisplay = AlertContent(symbol: "exclamationmark.triangle.fill", titleSymbol: "sun.max", title: "Always-On Display", content: "This option prevents display from sleeping. It may drain battery faster. Turn it off again if no longer needed")
}

struct GenericAlertView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    let alertContent:AlertContent
    let dismissAction:() -> ()
    let buttonAction:() -> ()
    
    var body: some View {
        ZStack {
            Color.white.opacity(alertContent.backgroundOpacity)
            VStack(spacing: 10) {
                Image(systemName: alertContent.symbol)
                    .foregroundColor(.yellow)
                    .font(.system(size: alertContent.symbolSize))
                HStack {
                    Image(systemName: alertContent.titleSymbol ?? "")
                    Text(alertContent.title)
                }
                .font(.system(size: 24))
                Text(alertContent.content)
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing])
                Button("Understood") {
                    
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.background2)
                    .standardShadow()
            )
        }
        .onTapGesture { dismissAction() }
    }
    
    func doStuff() {
        viewModel.showAlert_displayAlwaysOn = false
    }
}

struct GenericAlertView_Previews: PreviewProvider {
    static var previews: some View {
        GenericAlertView(alertContent: Alert.alwaysOnDisplay, dismissAction: {}, buttonAction: {})
    }
}

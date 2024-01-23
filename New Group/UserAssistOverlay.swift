//
//  UserAssistOverlay.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 30.01.2024.
//

import SwiftUI
import MyPackage

struct UserAssistOverlay: View {
    @AppStorage(Storagekey.assistUser) private var assistUser = true
    @State private var showAssistUser = true
    @Environment(ViewModel.self) private var viewModel
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        if assistUser && showAssistUser {
            AlertOverlay1("\(Image.three) Steps", "...to learn the basics") {
                Text("A stopwatch named '\(Names.testBubbleName)' will be created")
            } leftButtonAction: {
                assistUser = false
            } rightButtonAction: {
                viewModel.addExampleBubble()
                
                delayExecution(.now() + 0.05) {
                    secretary.palette(.hide)
                    SmallHelpOverlay.Model.shared.helpOverlay(.show)
                    SmallHelpOverlay.Model.shared.topmostView(.assistUser)
                }
            } dismissAction: {
                showAssistUser = false
            }
        }
    }
}

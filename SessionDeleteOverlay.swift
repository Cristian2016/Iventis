//
//  DeleteSessionConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//

import SwiftUI
import MyPackage

extension SessionDeleteOverlay {
    struct DeleteButtonStyle:ButtonStyle {
        var disabled:Bool = false
        func makeBody(configuration: Configuration) -> some View {
            let isPressed = configuration.isPressed
            let scale = isPressed ? 0.8 : 1.0
            
            configuration.label
                .scaleEffect(x: scale, y: scale)
                .disabled(disabled ? true : false)
        }
    }
}

struct SessionDeleteOverlay: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(Secretary.self) private var secretary
    
    @State private var input:Input?
    @State private var metrics:Metrics?
    
    //// MARK: 5
    var body: some View {
        ZStack {
            if input != nil {
                Background(.dark(.Opacity.overlay))
                    .onTapGesture { dismiss() }
                
                VStack (spacing:8) {
                    Text("Session \(input!.sessionRank)")
                        .font(.system(size: 16))
                        .allowsHitTesting(false)
                    deleteButton
                }
                .background { roundedBackground }
            }
        }
        .onChange(of: secretary.sessionToDelete) {
            if let value = $1 {
                let session = value.session
                input = Input(session: session, sessionRank: value.sessionRank)
                let color = Color.bubbleColor(forName: session.bubble?.color ?? "mint")
                metrics = Metrics(bubbleColor: color)
            } else {
                input = nil
            }
        }
    }
    
    // MARK: - Legos
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics!.backgroundRadius)
            .fill(.regularMaterial)
            .frame(width: metrics!.width, height: metrics!.height)
            .standardShadow()
            .onTapGesture {  }
    }
    
    private var deleteButton:some View {
        Button { deleteSession() } label: { deleteButtonLabel }
            .buttonStyle(DeleteButtonStyle())
    }
    
    private var deleteButtonLabel:some View {
        RoundedRectangle(cornerRadius: metrics!.buttonRadius)
            .fill(.red)
            .frame(width: 208, height: 90)
            .overlay {
                Text("Delete")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
    }
    
    // MARK: -
    ///dismiss view
    private func dismiss() { secretary.sessionToDelete = nil }
    
    //ViewModel 1
    private func removeFiveSecondsBar() {
        guard let bubbleRank = input!.session.bubble?.rank else { return }
        let isSameBubble = secretary.addNoteButton_bRank == Int(bubbleRank)
        let isLastSession = input!.session == input!.session.bubble?.lastSession
        if isLastSession, isSameBubble { secretary.addNoteButton_bRank = nil }
    }
    
    // MARK: -
    private func deleteSession() {
        withAnimation {
            //show confirmation only if deleted session corresponds to a calendar event
            if input!.session.eventID != nil {
                secretary.confirm_CalEventRemoved = input!.session.bubble?.rank
                delayExecution(.now() + 3) { self.secretary.confirm_CalEventRemoved = nil }
            }
            
            //⚠️ delete event from calendar first and then delete session from CoreData and Fused App
            CalendarManager.shared.deleteEvent(with: input!.session.eventID)
            
            //make SessionDAAlert go away after 0.3 seconds, so that user sees button tapped animation
            delayExecution(.now() + 0.25) {
                viewModel.deleteSession(input!.session)
                secretary.sessionToDelete = nil
            }
        }
        if secretary.addNoteButton_bRank != nil && input!.session.bubble?.sessions_.last == input!.session {
            secretary.addNoteButton_bRank = nil
        } //ViewModel 1
    }
}

extension SessionDeleteOverlay {
    struct Input {
        let session:Session
        let sessionRank:Int
    }
    
    struct Metrics {
        let backgroundRadius = CGFloat(44)
        let buttonRadius = CGFloat(32)
        
        let backgroundColor = Color("deleteActionAlert1")
        let bubbleColor:Color
        var width = CGFloat(220)
        let ratio = 1.50
        var height:CGFloat { width / ratio }
        let trashViewFont = Font.system(size: 26, weight: .medium)
        let buttonFont = Font.system(size: 28).weight(.medium)
    }
}

//
//  DeleteSessionConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//

import SwiftUI
import MyPackage

struct SessionDeleteActionAlert: View {
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    private let secretary = Secretary.shared
    
    @State private var input:Input?
    @State private var metrics:Metrics?
    
    //// MARK: -
    var body: some View {
        ZStack {
            if input != nil {
                Color.white.opacity(0.01).onTapGesture { cancelDeleteAction() }
                VStack (spacing:8) {
                    Text("Session \(input!.sessionRank)")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(Color("silverText"))
                        .allowsHitTesting(false)
                    deleteButton
                }
                .background { roundedBackground }
            }
        }
        .offset(y: -30)
        .onReceive(secretary.$sessionToDelete) {
            if let value = $0 {
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
            .fill(metrics!.backgroundColor)
            .frame(width: metrics!.width, height: metrics!.height)
            .standardShadow()
            .overlay {
                Push(.topLeft) {
                    Image.info
                        .font(.system(size: 26))
                        .foregroundColor(Color("deleteActionAlert1"))
                        .padding(-20)
                }
            }
            .onTapGesture { secretary.showSessionDeleteInfo = true }
    }
    
    private var deleteButton:some View {
        Button {
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
            if secretary.addNoteButton_bRank != nil { secretary.addNoteButton_bRank = nil } //ViewModel 1
        } label: {
            RoundedRectangle(cornerRadius: metrics!.buttonRadius)
                .fill(metrics!.bubbleColor)
                .frame(width: 210, height: 90)
                .overlay {
                    Text("Delete")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
        }
        .buttonStyle(BubbleDeleteActionAlert.DeleteButtonStyle())
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() { secretary.sessionToDelete = nil }
    
    //ViewModel 1
    private func removeFiveSecondsBar() {
        guard let bubbleRank = input!.session.bubble?.rank else { return }
        let isSameBubble = secretary.addNoteButton_bRank == Int(bubbleRank)
        let isLastSession = input!.session == input!.session.bubble?.lastSession
        if isLastSession, isSameBubble { secretary.addNoteButton_bRank = nil }
    }
}

extension SessionDeleteActionAlert {
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
        let ratio = 1.55
        var height:CGFloat { width/ratio }
        let trashViewFont = Font.system(size: 26, weight: .medium)
        let buttonFont = Font.system(size: 28).weight(.medium)
    }
}

extension SessionDeleteActionAlert {
    struct SessionDeleteInfoView:View {
        @State private var show = false
        
        var body: some View {
            ZStack {
                if show {
                    let title = "Delete Session"
                    let subtitle = "Any associated Calendar Event will be removed from the Calendar App"
                    
                    Color.black.opacity(0.6).ignoresSafeArea()
                    ThinMaterialLabel(title, subtitle) { infoContent } action: { dismiss() }
                        .font(.system(size: 20))
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
                    .thumbnail(130)
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text("**Delete** \(Image.tap) Tap")
                        Text("*Yellow Button*")
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text("**Dismiss** \(Image.tap) Tap")
                        Text("*Outside Gray Shape*")
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
}

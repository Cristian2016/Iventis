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
    
    let session:Session
    let sessionRank:String
    let metrics:Metrics
    
    struct Metrics {
        let backgroundRadius = CGFloat(44)
        let buttonRadius = CGFloat(25)
        
        let backgroundColor = Color("deleteActionViewBackground")
        let bubbleColor:Color
        var width = CGFloat(220)
        let ratio = 0.14
        var height:CGFloat { width/ratio }
        let buttonHeight:CGFloat = 78
        let trashViewFont = Font.system(size: 26, weight: .medium)
        let buttonFont = Font.system(size: 28).weight(.medium)
    }
    
    init(_ session:Session, _ sessionRank:String) {
        self.session = session
        self.sessionRank = sessionRank
        
        let bubbleColor = Color.bubbleColor(forName: session.bubble?.color ?? "mint")
        let metrics = Metrics(bubbleColor: bubbleColor)
        self.metrics = metrics
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() { viewModel.sessionToDelete = nil }
    
    //ViewModel 1
    private func removeFiveSecondsBar() {
        guard let bubbleRank = session.bubble?.rank else { return }
        let isSameBubble = viewModel.fiveSeconds_bRank == Int(bubbleRank)
        let isLastSession = session == session.bubble?.lastSession
        if isLastSession, isSameBubble { viewModel.fiveSeconds_bRank = nil }
    }
    
    //// MARK: -
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { cancelDeleteAction() }
            VStack (spacing:8) {
                trashLabel
                deleteButton
            }
            .font(.system(size: 32, weight: .medium, design: .rounded))
            .frame(width: metrics.width, height: metrics.height)
            .padding(4)
            .offset(x: 0, y: 4)
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .fill(metrics.backgroundColor)
                    .frame(width: metrics.width, height: metrics.height)
            }
            .padding(-1)
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .fill(Color("deleteActionAlert"))
                    .standardShadow()
            }
        }
    }
    
    // MARK: - Legos
    private var trashLabel:some View {
        HStack (spacing:2) {
            Image.trash
            Text("Delete")
        }
        .font(metrics.trashViewFont)
        .foregroundColor(.red)
    }
    
    private var deleteButton:some View {
        Button {
            withAnimation {
                //show confirmation only if deleted session corresponds to a calendar event
                if session.eventID != nil {
                    viewModel.confirm_CalEventRemoved = session.bubble?.rank
                    delayExecution(.now() + 3) { self.viewModel.confirm_CalEventRemoved = nil }
                }
                
                //⚠️ delete event from calendar first and then delete session from CoreData and Fused App
                CalendarManager.shared.deleteEvent(with: session.eventID)
                viewModel.deleteSession(session)
                viewModel.sessionToDelete = nil
            }
            if viewModel.fiveSeconds_bRank != nil { viewModel.fiveSeconds_bRank = nil } //ViewModel 1
        } label: {
            RoundedRectangle(cornerRadius: metrics.buttonRadius)
                .fill(metrics.bubbleColor)
                .frame(width: 208, height: 84)
                .overlay {
                    Text("Session \(sessionRank)")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
        }
        
    }
    
    private var deleteSessionButton: some View {
        RoundedRectangle(cornerRadius: metrics.buttonRadius)
            .fill(metrics.bubbleColor)
            .frame(height: metrics.buttonHeight)
    }
    
    // MARK: - Modifiers
}

struct SessionDeleteActionAlert_Previews: PreviewProvider {
    static let session:Session = {
        let session = Session(context: PersistenceController.preview.viewContext)
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        session.bubble = bubble
        session.bubble?.color = "orange"
        return session
    }()
    static var previews: some View {
        SessionDeleteActionAlert(session, "2")
    }
}

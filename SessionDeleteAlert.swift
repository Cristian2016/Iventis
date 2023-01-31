//
//  DeleteSessionConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//

import SwiftUI
import MyPackage

struct SessionDeleteAlert: View {
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    let session:Session
    let sessionRank:String
    let metrics:Metrics
    
    struct Metrics {
        let backgroundRadius = CGFloat(30)
        let backgroundColor = Color("deleteActionViewBackground")
        let buttonRadius = CGFloat(13)
        let bubbleColor:Color
        let width = CGFloat(174)
        let buttonHeight:CGFloat = 78
        let trashViewFont = Font.system(size: 28).weight(.medium)
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
    
    //// MARK: -
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { cancelDeleteAction() }
            VStack (spacing:8) {
                trashView
                deleteSessionView
                    .overlay {
                        Text("Session \(sessionRank)").foregroundColor(metrics.bubbleColor)
                    }
                    .onTapGesture {
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
                        if viewModel.showUndoStartAddTagBar_bRank != nil { viewModel.showUndoStartAddTagBar_bRank = nil } //ViewModel 1
                    }
            }
            .font(.system(size: 30).weight(.medium))
            .frame(width: metrics.width)
            .padding(16)
            .padding([.top], 4)
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .strokeBorder(metrics.bubbleColor, lineWidth: 4)
            }
            .padding(-1)
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .fill(Color.background)
                    .standardShadow()
            }
        }
    }
    
    // MARK: - Legos
    private var trashView:some View {
        HStack (spacing:2) {
            Image.trash
            Text("Delete")
        }
        .font(metrics.trashViewFont)
        .foregroundColor(.red)
    }
    
    private var deleteSessionView: some View {
        return RoundedRectangle(cornerRadius: metrics.buttonRadius)
            .stroke(metrics.bubbleColor, lineWidth: 4)
            .frame(height: metrics.buttonHeight)
    }
    
    // MARK: - Modifiers
}

struct SessionDeleteAlert_Previews: PreviewProvider {
    static let session:Session = {
        let session = Session(context: PersistenceController.preview.viewContext)
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        session.bubble = bubble
        session.bubble?.color = "red"
        return session
    }()
    static var previews: some View {
        SessionDeleteAlert(session, "2")
    }
}

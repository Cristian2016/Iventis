//
//  DeleteSessionConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//

import SwiftUI

struct DeleteSessionConfirmationView: View {
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    let session:Session
    let sessionRank:String
    let metrics:Metrics
    
    struct Metrics {
        let backgroundRadius = CGFloat(30)
        let backgroundColor = Color("deleteActionViewBackground")
        let width = CGFloat(170)
        let buttonRadius = CGFloat(13)
        let bubbleColor:Color
        let buttonHeight:CGFloat = 74
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
                            //⚠️ delete event from calendar first and then delete session from CoreData and Fused App
                            CalendarManager.shared.deleteEvent(with: session.eventID)
                            viewModel.deleteSession(session)
                            viewModel.sessionToDelete = nil
                        }
                    }
            }
            .font(.system(size: 30).weight(.medium))
            .frame(width: metrics.width)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .strokeBorder(metrics.bubbleColor, lineWidth: 4)
            }
            .padding(-1)
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .fill(Color.background)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
        }
    }
    
    // MARK: - Legos
    private var trashView:some View {
        HStack (spacing:2) {
            Image.trash
            Text("Delete")
        }
        .font(.system(size: 30).weight(.medium))
        .foregroundColor(.red)
    }
    
    private var deleteSessionView: some View {
        return RoundedRectangle(cornerRadius: metrics.buttonRadius)
            .stroke(metrics.bubbleColor, lineWidth: 4)
            .frame(height: metrics.buttonHeight)
    }
    
    // MARK: - Modifiers
}

struct DeleteSessionConfirmationView_Previews: PreviewProvider {
    static let session:Session = {
        let session = Session(context: PersistenceController.preview.viewContext)
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        session.bubble = bubble
        session.bubble?.color = "red"
        return session
    }()
    static var previews: some View {
        DeleteSessionConfirmationView(session, "2")
    }
}

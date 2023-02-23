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
    
    @State private var metrics:Metrics?
    
    struct Input {
        let session:Session
        let sessionRank:Int
    }
    
    @State private var input:Input?
    
    struct Metrics {
        let backgroundRadius = CGFloat(44)
        let buttonRadius = CGFloat(28)
        
        let backgroundColor = Color("deleteActionViewBackground")
        let bubbleColor:Color
        var width = CGFloat(220)
        let ratio = 1.25
        var height:CGFloat { width/ratio }
        let buttonHeight:CGFloat = 78
        let trashViewFont = Font.system(size: 26, weight: .medium)
        let buttonFont = Font.system(size: 28).weight(.medium)
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
    
    //// MARK: -
    var body: some View {
        ZStack {
            if input != nil {
                Color.white.opacity(0.01).onTapGesture { cancelDeleteAction() }
                VStack (spacing:8) {
                    trashLabel
                    deleteButton
                }
                .offset(x: 0, y: 12)
                .background { roundedBackground }
            }
           
        }
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
    }
    
    private var trashLabel:some View {
        HStack (spacing:2) {
            Image.trash
            Text("Delete")
        }
        .font(metrics!.trashViewFont)
        .foregroundColor(.red)
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
                .frame(width: 204, height: 84)
                .overlay {
                    Text("Session \(input!.sessionRank)")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
        }
        .buttonStyle(BubbleDeleteActionAlert.DeleteButtonStyle())
    }
}

//struct SessionDeleteActionAlert_Previews: PreviewProvider {
//    static let session:Session = {
//        let session = Session(context: PersistenceController.preview.viewContext)
//        let bubble = Bubble(context: PersistenceController.preview.viewContext)
//        session.bubble = bubble
//        session.bubble?.color = "orange"
//        return session
//    }()
//    static var previews: some View {
//        SessionDeleteActionAlert(session, "2")
//    }
//}

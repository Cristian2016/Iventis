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
    let metrics:Metrics
    
    struct Metrics {
        let backgroundRadius = CGFloat(30)
        let backgroundColor = Color("deleteActionViewBackground")
        let width = CGFloat(170)
        let buttonRadius = CGFloat(13)
        let bubbleColor:Color
        let buttonHeight:CGFloat = 74
    }
    
    init(_ session:Session) {
        self.session = session
        
        let bubbleColor = Color.bubbleColor(forName: session.bubble?.color ?? "mint")
        let metrics = Metrics(bubbleColor: bubbleColor)
        self.metrics = metrics
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() {
        viewModel.deleteAction_bRank = nil
        layoutViewModel.deleteActionViewOffset = nil
    }
    
    //// MARK: -
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { cancelDeleteAction() }
            VStack (spacing:8) {
                trashView
                deleteSessionView
                    .overlay {
                        Text("Session").foregroundColor(metrics.bubbleColor)
                    }
                    .onTapGesture {
                        withAnimation {
                            viewModel.deleteSession(session)
                        }
                    }
            }
            .font(.system(size: 30).weight(.medium))
            .frame(width: metrics.width)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .stroke(metrics.backgroundColor, lineWidth: 4)
            }
        }
//        .offset(x: 0, y: layoutViewModel.deleteActionViewOffset ?? 0)
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
        DeleteSessionConfirmationView(session)
    }
}

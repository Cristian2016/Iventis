//
//  DeleteActionView1.swift
//  Timers
//
//  Created by Cristian Lapusan on 04.05.2022.
// markdown https://swiftuirecipes.com/user/pages/01.blog/markdown-in-swiftui-text/preview.gif

import SwiftUI

///same size on each device
struct DeleteView: View {
    let bubble:Bubble?
    let bubbleColor:Color
    
    @EnvironmentObject private var viewModel:ViewModel
    
    //internal properties
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    static let height = CGFloat(250)
    let backgroundColor = Color("deleteActionViewBackground")
    let backgroundRadius = CGFloat(30)
    let buttonRadius = CGFloat(13)
    
    var body: some View {
            ZStack {
                Color.white.opacity(0.01)
                    .onTapGesture { viewModel.showDeleteAction_bRank = nil }
                RoundedRectangle(cornerRadius: backgroundRadius)
                    .fill(backgroundColor)
                    .frame(width: width, height: width/ratio)
                //                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
                    .overlay {
                        ZStack {
                            VStack (spacing:6) {
                                trashView
                                
                                VStack {
                                    deleteBubbleView
                                        .onTapGesture { withAnimation {
                                            viewModel.delete(bubble!)
                                            viewModel.showDeleteAction_bRank = nil
                                        } }
                                    deleteHistoryView
                                        .onTapGesture { withAnimation {
                                            if !bubble!.sessions_.isEmpty {
                                                viewModel.reset(bubble!)
                                                viewModel.showDeleteAction_bRank = nil
                                            }
                                        } }
                                }
                                .font(.system(size: 30).weight(.medium))
                                .padding([.bottom], 6)
                            }
                        }
                        .padding()
                    }
            }
            .offset(x: 0, y: viewModel.deleteViewOffset ?? 0)
    }
    
    // MARK: - Init
    init(_ bubble:Bubble?) {
        self.bubbleColor = Color.bubbleColor(forName: bubble?.color ?? "mint")
        self.bubble = bubble
    }
    
    // MARK: - Legos
    private var trashView:some View {
        HStack (alignment:.firstTextBaseline, spacing:2) {
            Image(systemName: "trash.fill")
            Text("Delete")
        }
        .modifier(TrashModifier())
    }
    
    private var deleteBubbleView:some View {
        RoundedRectangle(cornerRadius: buttonRadius)
            .foregroundColor(bubbleColor)
            .overlay { Text("Bubble").foregroundColor(.white) }
    }
    
    private var deleteHistoryView: some View {
        let historyAvailable = bubble?.sessions_.isEmpty ?? false
        return RoundedRectangle(cornerRadius: buttonRadius)
            .foregroundColor(historyAvailable ? bubbleColor.opacity(0.3) : bubbleColor)
            .overlay { Text("History \(bubble?.sessions_.count ?? 0)")
                .foregroundColor(historyAvailable ? .white.opacity(0.3) :  .white) }
    }
    
    // MARK: - Modifiers
    struct TrashModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding([.top], 0)
                .offset(x: -11, y: 0)
                .font(.system(size: 30).weight(.medium))
                .foregroundColor(.red)
        }
    }
}

//struct DeleteActionView1_: PreviewProvider {
//    static var previews: some View {
//        DeleteActionView(nil, nil)
//    }
//}

//
//  DeleteActionView1.swift
//  Timers
//
//  Created by Cristian Lapusan on 04.05.2022.
//

import SwiftUI

///same size on each device
struct DeleteActionView: View {
    let bubble:Bubble?
    let bubbleColor:Color
    
    @Binding var showDeleteAction:(show:Bool,rank:Int?)
    @Binding var predicate:NSPredicate?
    @EnvironmentObject private var viewModel:ViewModel
    let deleteActionOffset:CGFloat //I used the preference key approach
    
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
                .onTapGesture { showDeleteAction.show = false }
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
                                        showDeleteAction.show = false
                                        predicate = nil
                                    } }
                                deleteHistoryView
                                    .onTapGesture { withAnimation {
                                        if !bubble!.sessions_.isEmpty {
                                            viewModel.reset(bubble!)
                                            showDeleteAction.show = false
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
        .offset(x: 0, y: deleteActionOffset)
    }
    
    // MARK: - Init
    init(_ bubble:Bubble?,
         _ showDeleteAction:Binding<(show:Bool, rank:Int?)>,
         _ predicate:Binding<NSPredicate?>,
         _ deleteActionOffset:CGFloat) {
                        
        self.bubbleColor = Color.bubble(for: bubble?.color ?? "mint")
        _showDeleteAction = Binding(projectedValue: showDeleteAction)
        self.bubble = bubble
        _predicate = Binding(projectedValue: predicate)
        self.deleteActionOffset = deleteActionOffset
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
        let historyAvailable = bubble!.sessions_.isEmpty
        return RoundedRectangle(cornerRadius: buttonRadius)
            .foregroundColor(historyAvailable ? bubbleColor.opacity(0.3) : bubbleColor)
            .overlay { Text("History \(bubble!.sessions_.count)")
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

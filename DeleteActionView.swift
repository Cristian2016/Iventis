//
//  DeleteActionView1.swift
//  Timers
//
//  Created by Cristian Lapusan on 04.05.2022.
//

import SwiftUI

struct DeleteActionView: View {
    let bubble:Bubble?
    let bubbleColor:Color
    @Binding var showDeleteAction:(show:Bool,rank:Int?)
    @Binding var predicate:NSPredicate?
    @EnvironmentObject private var viewModel:ViewModel
    
    init(_ bubble:Bubble?,
         _ showDeleteAction:Binding<(show:Bool, rank:Int?)>,
         _ predicate:Binding<NSPredicate?>) {
        
        self.bubbleColor = Color.bubble(for: bubble?.color ?? "mint")
        _showDeleteAction = Binding(projectedValue: showDeleteAction)
        self.bubble = bubble
        _predicate = Binding(projectedValue: predicate)
    }
    
    //internal properties
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture {
                    showDeleteAction.show = false
                }
            RoundedRectangle(cornerRadius: 30)
                .frame(width: width, height: width/ratio)
                .foregroundColor(Color("deleteActionViewBackground"))
                .overlay {
                    ZStack {
                        VStack (spacing:6) {
                            HStack (alignment:.firstTextBaseline, spacing:2) {
                                Image(systemName: "trash.fill")
                                Text("Delete")
                            }
                            .padding([.top], 0)
                            .offset(x: -11, y: 0)
                            .font(.system(size: 30).weight(.medium))
                            .foregroundColor(.red)
                            VStack {
                                RoundedRectangle(cornerRadius: 13)
                                    .overlay { Text("Bubble").foregroundColor(.white) }
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.delete(bubble!)
                                            showDeleteAction.show = false
                                            predicate = nil
                                        }
                                    }
                                RoundedRectangle(cornerRadius: 13)
                                    .overlay { Text("History").foregroundColor(.white) }
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.reset(bubble!)
                                            showDeleteAction.show = false
                                        }
                                    }
                            }
                            .foregroundColor(bubbleColor)
                            .font(.system(size: 30).weight(.medium))
                            .padding([.bottom], 6)
                        }
                    }
                    .padding()
                }
        }
    }
}

//struct DeleteActionView1_: PreviewProvider {
//    static var previews: some View {
//        DeleteActionView(nil, nil)
//    }
//}

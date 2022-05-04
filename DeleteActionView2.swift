//
//  DeleteActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
//

import SwiftUI

struct DeleteActionView2: View {
    @Binding var showDeleteAction:(show:Bool, rank:Int?)
    @Binding var predicate:NSPredicate?
    @Binding var showDetail:(show:Bool, rank:Int?)
    
    let ultrathinBackgroundRadius = CGFloat(34)
    
    init(_ showDeleteAction:Binding<(show:Bool, rank:Int?)>,
         _ predicate:Binding<NSPredicate?>,
         _ showDetail:Binding<(show:Bool, rank:Int?)>) {
        
        _showDeleteAction = Binding(projectedValue: showDeleteAction)
        _predicate = Binding(projectedValue: predicate)
        _showDetail = Binding(projectedValue: showDetail)
    }
    
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    
    var body: some View {
        ZStack {
            clearBackground
            ZStack {
                ultraThinBackground
                    .overlay {
                        VStack {
                            HStack {
                                deleteTitle
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 20, leading: 18, bottom: 6, trailing: 0))
                            
                            VStack (spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                    Text("Bubble")
                                        .foregroundColor(.white)
                                        .font(.system(size: 30).weight(.medium))
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                    Text("History")
                                        .foregroundColor(.white)
                                        .font(.system(size: 30).weight(.medium))
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 22, trailing: 16))
                        }
                    }
            }
            .frame(width: width, height: width/ratio)
            .padding()
        }
        
//        .onTapGesture {
//            let bubble = bubble(for: showDeleteAction.rank!)
//            viewModel.delete(bubble)
//            //set predicate to nil in case any filtered search is going on
//            predicate = nil
//            showDetail.show = false
//            showDeleteAction = (false, nil)
//        }
       
    }
    
    var clearBackground:some View {
        Color.white.opacity(0.001) //view's background
            .ignoresSafeArea()
            .onTapGesture { showDeleteAction.show = false }
    }
    
    var ultraThinBackground:some View {
        RoundedRectangle(cornerRadius: ultrathinBackgroundRadius)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: ultrathinBackgroundRadius))
    }
    
    var deleteTitle:some View {
        Text("\(Image.trash) Delete")
            .foregroundColor(.background)
            .font(.system(size: 30))
            .fontWeight(.medium)
    }
}

//struct DeleteActionView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteActionView(showDeleteAction: .constant((false, nil)))
//    }
//}

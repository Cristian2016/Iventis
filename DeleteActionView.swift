//
//  DeleteActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
//

import SwiftUI

struct DeleteActionView: View {
    @Binding var showDeleteAction:(show:Bool, rank:Int?)
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture { showDeleteAction.show = false }
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                .fill(Color("deleteActionViewBackground"))
                    
                VStack {
                    Text("\(Image.trash) Delete")
                        .foregroundColor(.red)
                        .font(.title)
                        .fontWeight(.medium)
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                        Text("Bubble")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                        Text("History")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
                .padding(15)
            }
            .frame(width: width, height: width/ratio)
            .padding()
        }
       
    }
}

struct DeleteActionView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteActionView(showDeleteAction: .constant((false, nil)))
    }
}

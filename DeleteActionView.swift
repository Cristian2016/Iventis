//
//  DeleteActionView1.swift
//  Timers
//
//  Created by Cristian Lapusan on 04.05.2022.
//

import SwiftUI

struct DeleteActionView: View {
    //external properties
    //bubble.rank or something
    //predicate
    //bubble.color
    let bubble:Bubble?
    let bubbleColor:Color
    
    init(_ bubble:Bubble?) {
        self.bubble = bubble
        self.bubbleColor = Color.bubble(for: bubble?.color ?? "mint")
    }
    
    //internal properties
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    
    var body: some View {
        ZStack {
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
                                    .overlay {
                                        Text("Bubble").foregroundColor(.white)
                                    }
                                RoundedRectangle(cornerRadius: 13)
                                    .overlay { Text("History").foregroundColor(.white) }
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

struct DeleteActionView1_: PreviewProvider {
    static var previews: some View {
        DeleteActionView(nil)
    }
}

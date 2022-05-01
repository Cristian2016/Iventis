//
//  HorizontalTable.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
//

import SwiftUI

struct HorizontalTable: View {
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack {
                    ForEach (0..<5) { index in
                        TopCell().onTapGesture {
                            proxy.scrollTo(2, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
}

struct TopCell:View {
    var body: some View {
        ZStack {
            VStack {
                Text("1")
                    .font(.system(size: 30))
                Text("Today")
                Text("37 min 22 sec")
            }
            .frame(width: 100, height: 100)
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink))
    }
}

//struct HorizontalTable_Previews: PreviewProvider {
//    static var previews: some View {
//        HorizontalTable(bubble: <#Bubble#>)
//    }
//}

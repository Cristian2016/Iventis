//
//  SomeView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.06.2022.
//

import SwiftUI

struct Note_InfoView: View {
//    @Binding var entry:String
    
    var body: some View {
        VStack (alignment: .leading) {
            Divider().frame(maxWidth: .infinity)
            
            VStack (alignment: .leading) {
                Text("\(Image(systemName: "square.and.arrow.down")) Save Note")
                
                VStack (alignment: .leading) {
//                    Text("Tap \(Image(systemName: "plus.square")) or")
                    Text("Tap Outside Table")
                }
                .foregroundColor(.lightGray)
            }
            
            Divider()
                .frame(maxWidth: .infinity)
                .background { Rectangle().fill(Color.lightGray) }
            
            VStack (alignment: .leading) {
                Text("\(Image(systemName: "trash")) Delete")
                Text("\(Image(systemName: "arrow.left.circle")) Swipe From")
                    .foregroundColor(.lightGray)
                Text("Screen Edge")
                    .foregroundColor(.lightGray)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct SomeView_Previews: PreviewProvider {
    static var previews: some View {
        Note_InfoView()
    }
}

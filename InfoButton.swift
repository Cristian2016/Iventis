//
//  InfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.10.2022.
//

import SwiftUI

struct InfoButton: View {
    var color:Color = .gray
    let tapAction:() -> ()
    
    var body: some View {
        Image.info
            .foregroundColor(color)
            .font(.system(size: 30))
            .padding()
            .background {
                Circle()
                    .fill(Color.transparent)
                    .onTapGesture { tapAction() }
            }
    }
}

struct InfoButton_Previews: PreviewProvider {
    static var previews: some View {
        InfoButton {  /* tap action */ }
    }
}

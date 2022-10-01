//
//  InfoButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.10.2022.
//

import SwiftUI

struct InfoButton: View {
    let tapAction:() -> ()
    
    var body: some View {
        Push(.topRight) {
            Image.info
                .foregroundColor(.infoButton)
                .font(.system(size: 30))
                .padding()
                .background {
                    Circle()
                        .fill(Color.transparent)
                        .onTapGesture { tapAction() }
                }
        }
        .padding([.top])
        .padding([.top])
    }
}

struct InfoButton_Previews: PreviewProvider {
    static var previews: some View {
        InfoButton {  /* tap action */ }
    }
}

//
//  HelpActionButton.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.05.2022.
//

import SwiftUI

struct HelpActionButton: View {
    let fontSize = CGFloat(40)
    
    var body: some View {
        Button {
            
        } label: {
            Label {
//                Text("Help")
//                    .font(.title2)
            } icon: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: fontSize))
                    .foregroundColor(.yellow)
            }
        }
        .tint(.yellow)
        .buttonStyle(.borderless)
    }
}

struct HelpActionButton_Previews: PreviewProvider {
    static var previews: some View {
        HelpActionButton()
    }
}

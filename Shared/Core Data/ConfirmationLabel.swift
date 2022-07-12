//
//  ConfirmationLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import SwiftUI

struct ConfirmationLabel<Content:View>: View {
    let content:Content
    let isDestructive:Bool
    let action:() -> ()
    
    init(isDestructive: Bool = false,
         @ViewBuilder content: () -> Content,
        action: @escaping () -> ()) {
        
        self.content = content()
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.7)
                .onTapGesture { action() }
            content
                .foregroundColor(.white)
                .font(.system(size: 30))
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isDestructive ? Color.red : .green)
                }
                .padding()
        }
    }
}

struct ConfirmationLabel_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationLabel { Text("ok") } action: {  /* some code to run */ }
    }
}

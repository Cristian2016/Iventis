//
//  PusherView.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct Push<Content:View>: View {
    let content:Content
    let position:Position
    
    init(_ position:Position, @ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.position = position
    }
    
    var body: some View { makePusher }
    
    enum Position {
        case topLeft
        case topRight
        case topMiddle
        
        case bottomLeft
        case bottomRight
        case bottomMiddle
        
        case middle
        case leading
        case trailing
    }
    
    @ViewBuilder
    private var makePusher:some View {
        switch position {
            case .topLeft:
                VStack { HStack { content; Spacer() } ;Spacer() }
            case .topRight:
                VStack { HStack { Spacer() ;content } ; Spacer() }
            case .bottomRight:
                VStack { Spacer(); HStack { Spacer() ;content } }
            case .bottomLeft:
                VStack {  Spacer(); HStack { content ; Spacer() } }
            case .topMiddle:
                VStack { content; Spacer() }
            case .bottomMiddle:
                VStack { Spacer(); content }
                
            case .middle:
                HStack {
                    Spacer(); content; Spacer()
                }
            case .leading:
                HStack {
                    content; Spacer()
                }
            case .trailing:
                HStack {
                    Spacer(); content
                }
        }
    }
}

struct PushView_Previews: PreviewProvider {
    static var previews: some View {
        Push(.bottomLeft) { Text("ok") }
            .padding()
    }
}

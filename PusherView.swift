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
    init(_ content:Content, _ position:Position) {
        self.content = content
        self.position = position
    }
    
    var body: some View { makePusher }
    
    enum Position {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
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
        }
    }
}

struct PushView_Previews: PreviewProvider {
    static var previews: some View {
        Push(Text("Baby"), .bottomLeft)
            .padding()
    }
}

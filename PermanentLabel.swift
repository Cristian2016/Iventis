//
//  PermanentLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.03.2023.
//

import SwiftUI

struct PermanentLabel<Content:View>: View {
    
    private let title:String
    private let content:Content
    
    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom, 1)
                .font(.system(size: 28, weight: .medium))
                .minimumScaleFactor(0.1)
            Divider().frame(maxWidth: 300)
            content
        }
        .offset(x: 40) //the width of the LeftStrip
    }
    
    init(title:String, @ViewBuilder _ content:() -> Content) {
        self.title = title
        self.content = content()
    }
}

struct PermanentLabel_Previews: PreviewProvider {
    static var previews: some View {
        PermanentLabel(title: "Quick Start") { VStack {}}
    }
}

//
//  PermanentLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.03.2023.
//

import SwiftUI

struct PermanentLabel<Content:View>: View {
    
    private let title:String
    private var subtitle:String?
    private let content:Content
    
    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom, 1)
                .font(.system(size: 28, weight: .medium))
                .minimumScaleFactor(0.1)
            subtitleView
            Divider().frame(maxWidth: 300)
            content
        }
        .offset(x: 20) //the width of the LeftStrip is 20
        .padding()
    }
    
    @ViewBuilder
    private var subtitleView:some View {
        if let subtitle = subtitle {
            Text("*\(subtitle)*").forceMultipleLines()
        }
    }
    
    init(title:String, _ subtitle:String? = nil, @ViewBuilder _ content:() -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
}

struct PermanentLabel_Previews: PreviewProvider {
    static var previews: some View {
        PermanentLabel(title: "Quick Start") { VStack {}}
    }
}

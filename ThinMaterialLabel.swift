//
//  PaletteLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.02.2023.
//

import SwiftUI

struct ThinMaterialLabel<Content:View>: View {
    struct Metrics {
        let backgroundRadius = CGFloat(20)
    }
    
    init(title:String? = nil, subtitle:String? = nil, @ViewBuilder _ content:() -> Content, action: @escaping () -> ()) {
        self.content = content()
        self.action = action
        self.title = title
        self.subtitle = subtitle
    }
    
    private var title:String?
    private var subtitle:String?
    
    let content:Content
    private let action:() -> ()
    
    @State private var hide = false
    
    private let metrics = Metrics()
    
    var body: some View {
        VStack {
            if let title = title {
                Text(title)
                    .padding(.bottom, 1)
                    .font(.system(size: 28, weight: .medium))
                    .minimumScaleFactor(0.1)
                if let subtitle = subtitle { Text("*\(subtitle)*") }
                Divider().frame(maxWidth: 300)
            }
            content
            dismissButton
        }
        .padding()
        .background { roundedBackground }
        .frame(maxWidth: 364)
    }
    
    // MARK: - Legos
    private var dismissButton:some View {
        Button { action() } label: {
            Text("OK").frame(maxWidth: .infinity)
        }
        .tint(.red)
        .buttonStyle(.borderedProminent)
        .font(.system(size: 24, weight: .medium))
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.backgroundRadius)
            .fill(.regularMaterial)
            .standardShadow()
    }
    
    // MARK: -
}

struct PaletteLabel_Previews: PreviewProvider {
    static var content:some View {
        VStack(alignment: .leading) {
            Text("Existing Calendar Events will not be removed by any of the two actions")
        }
    }
    static var previews: some View {
        ThinMaterialLabel { content } action: { }
    }
}

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
    
    init(_ title:String? = nil, _ subtitle:LocalizedStringKey? = nil, @ViewBuilder _ content:() -> Content, action: @escaping () -> (), moreInfo: @escaping () -> ()) {
        self.content = content()
        self.action = action
        self.moreInfo = moreInfo
        self.title = title
        self.subtitle = subtitle
    }
    
    private var title:String?
    private var subtitle:LocalizedStringKey?
    
    let content:Content
    private let action:() -> ()
    private let moreInfo:() -> ()
    
    @State private var hide = false
    
    private let metrics = Metrics()
    
    var body: some View {
        VStack {
            if let title = title {
                Text(title)
                    .padding(.bottom, 1)
                    .font(.system(size: 28, weight: .medium))
                    .minimumScaleFactor(0.1)
                subtitleView
                Divider().frame(maxWidth: 300)
            }
            content
            HStack {
                dismissButton
                moreInfoButton
            }
        }
        .padding()
        .background { roundedBackground }
        .frame(maxWidth: 364)
    }
    
    // MARK: - Legos
    @ViewBuilder
    private var subtitleView:some View {
        if let subtitle = subtitle {
            Text(subtitle)
                .foregroundColor(.secondary)
                .forceMultipleLines()
                .italic()
        }
    }
    
    private var dismissButton:some View {
        Button { action() } label: {
            Text("Dismiss")
                .frame(maxWidth: .infinity)
        }
        .tint(.red)
        .buttonStyle(.bordered)
        .font(.system(size: 24, weight: .medium))
    }
    
    private var moreInfoButton:some View {
        Button { moreInfo() } label: {
            Label("More", systemImage: "info.square.fill")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
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
        ThinMaterialLabel { content } action: { } moreInfo: { }
    }
}

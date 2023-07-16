//
//  PaletteLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.02.2023.
//1 prevents to grow too much in landscape mode

import SwiftUI
import MyPackage

struct MaterialLabel<Content:View>: View {
    struct Metrics {
        let backgroundRadius = CGFloat(20)
        let mediumFont = Font.system(size: 20)
    }
    
    init(_ title:String? = nil,
         _ subtitle:LocalizedStringKey? = nil,
         @ViewBuilder _ content:() -> Content,
         _ action: @escaping () -> (),
         _ moreInfo: @escaping () -> ()) {
        
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
        ZStack {
            Background(.dark())
                .onTapGesture { action() }
            
            VStack(spacing: 4) {
                titleView
                subtitleView
                
                content.font(metrics.mediumFont)
                
                Divider()
                
                HStack {
                    shakeForInfo
                    moreInfoButton
                }
            }
            .padding()
            .background { materialBackground }
            .frame(maxWidth: 364) //1
        }
    }
    
    // MARK: - Legos
    @ViewBuilder
    private var titleView:some View {
        if let title = title {
            Text(title)
                .font(.system(size: 24, weight: .medium))
                .minimumScaleFactor(0.1)
        }
    }
    
    @ViewBuilder
    private var subtitleView:some View {
        if let subtitle = subtitle {
            Text(subtitle)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .forceMultipleLines()
                .multilineTextAlignment(.center)
        }
    }
    
    private var shakeForInfo:some View {
        Label("*Shake for Info*", systemImage: "iphone.radiowaves.left.and.right")
            .font(.system(size: .minFontSize))
    }
    
    private var moreInfoButton:some View {
        Button { moreInfo() } label: {
            Label("*More*", systemImage: "info.square.fill")
                .font(.system(size: 20))
        }
    }
    
    private var materialBackground:some View {
        RoundedRectangle(cornerRadius: metrics.backgroundRadius).fill(.thickMaterial)
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
        MaterialLabel { content } _: { } _: { }
    }
}

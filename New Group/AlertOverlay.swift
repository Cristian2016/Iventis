//
//  PaletteLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.02.2023.
//1 prevents to grow too much in landscape mode

import SwiftUI
import MyPackage

struct AlertOverlay<Content:View>: View {
    @Environment(Secretary.self) private var secretary
    @AppStorage(Storagekey.showDismissHint) private var showDismissHint = 0
    
    private var title:LocalizedStringKey?
    private var subtitle:LocalizedStringKey?
    
    let content:Content
    private let dismiss:() -> ()
    private let leftAction:(() -> ())?
    
    @State private var hide = false
    
    private let metrics = Metrics()
    
    var body: some View {
        ZStack {
            Background(.dark())
                .onTapGesture { dismiss() }
            
            VStack(spacing: 4) {
                titleView
                subtitleView
                
                content.font(metrics.mediumFont)
                    .padding([.top, .bottom], 10)
                
                Divider()
                
                HStack {
                    if let leftAction = leftAction {
                        Button {
                            leftAction()
                        } label: {
                            Label("Never Show", systemImage: "lightbuld")
                                .frame(maxWidth: .infinity)
                                .contentShape(.rect)
                        }
                        .tint(.red)
                        
                        Divider().frame(height: 20)
                    }
                    
                    Button {
                        secretary.bigHelpOverlay(.show(animate: true))
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .contentShape(.rect)
                    }
                    
                    .tint(.blue)
                }
                .labelStyle(.titleOnly)
                .font(.system(size: 20, weight: .medium))
            }
            .padding()
            .background(.thickMaterial, in: .rect(cornerRadius: metrics.backgroundRadius))
            .frame(maxWidth: 364) //1
            .overlay(alignment: .bottom) {
                if showDismissHint < 6 { //shows hint 5x
                    DismissHint()
                        .onAppear { showDismissHint += 1 }
                }
            }
        }
    }
    
    // MARK: - Legos
    @ViewBuilder
    private var titleView:some View {
        if let title = title {
            Text(title)
                .font(.system(size: 24, weight: .medium))
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
    
    // MARK: -
    struct Metrics {
        let backgroundRadius = CGFloat(20)
        let mediumFont = Font.system(size: 20)
    }
    
    init(_ title:LocalizedStringKey? = nil,
         _ subtitle:LocalizedStringKey? = nil,
         @ViewBuilder _ content:() -> Content,
         dismiss: @escaping () -> (),
         leftAction: (() -> ())? = nil) {
        
        self.content = content()
        self.dismiss = dismiss
        self.leftAction = leftAction
        self.title = title
        self.subtitle = subtitle
    }
}

struct AlertOverlay1<Content:View>: View {
    @AppStorage(Storagekey.showDismissHint) private var showDismissHint = 0
    
    private var title:LocalizedStringKey?
    private var subtitle:LocalizedStringKey?
    
    let content:Content
    private let leftButtonAction:() -> ()
    private let rightButtonAction:(() -> ())
    private let dismiss:(() -> ())
    
    @State private var hide = false
    
    private let metrics = Metrics()
    
    var body: some View {
        ZStack {
            Background(.dark())
                .onTapGesture { dismiss() }
            
            VStack(spacing: 4) {
                titleView
                subtitleView
                
                content.font(metrics.mediumFont)
                    .padding([.top, .bottom], 10)
                
                Divider()
                
                HStack {
                    Button {
                        leftButtonAction()
                    } label: {
                        Label("No, thanks", systemImage: "questionmark.circle")
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .contentShape(.rect)
                    }
                    .tint(.red)
                    
                    Divider().frame(height: 20)
                    
                    Button {
                        rightButtonAction()
                    } label: {
                        Label("Show", systemImage: "lightbuld")
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    }
                    .tint(.blue)
                }
                .labelStyle(.titleOnly)
                .font(.system(size: 20, weight: .medium))
            }
            .padding()
            .background { materialBackground }
            .frame(maxWidth: 364) //1
            .overlay(alignment: .bottom) {
                if showDismissHint < 6 { //shows hint 5x
                    DismissHint()
                        .onAppear { showDismissHint += 1 }
                }
            }
        }
    }
    
    // MARK: - Legos
    @ViewBuilder
    private var titleView:some View {
        if let title = title {
            Text(title)
                .font(.system(size: 24, weight: .medium))
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
    
    private var materialBackground:some View {
        RoundedRectangle(cornerRadius: metrics.backgroundRadius).fill(.thickMaterial)
    }
    
    // MARK: -
    struct Metrics {
        let backgroundRadius = CGFloat(20)
        let mediumFont = Font.system(size: 20)
    }
    
    init(_ title:LocalizedStringKey? = nil,
         _ subtitle:LocalizedStringKey? = nil,
         @ViewBuilder _ content:() -> Content,
         leftButtonAction: @escaping () -> (),
         rightButtonAction: @escaping () -> (), dismissAction: @escaping () -> ()) {
        
        self.content = content()
        
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
        self.dismiss = dismissAction
        
        self.title = title
        self.subtitle = subtitle
    }
}

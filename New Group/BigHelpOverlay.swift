//
//  HelpViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.12.2023.
//

import SwiftUI

struct BigHelpOverlay: View {
    @Environment(Secretary.self) private var secretary
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        @Bindable var model = SmallHelpOverlay.Model.shared
        
        NavigationStack(path: $model.path) {
            List {
                Section {
                    basicsSection
                        .listRowSeparator(.hidden)
                        .onOpenURL { handleOpen($0) }
                } header: {
                    Text("\(Image(systemName: "square.arrowtriangle.4.outward")) OVERVIEW")
                        .backgroundStyle(.secondary)
                }
                .listSectionSeparator(.visible, edges: .top)
                
                Section {
                    Button {
                        openYouTubeTutorial()
                    } label: {
                        Label("Watch Tutorial", systemImage: "safari")
                            .foregroundStyle(.blue)
                    }
                    
                    ForEach(HelpCellContent.all) { content in
                        NavigationLink(value: content) {
                            Label(content.title.rawValue, systemImage: content.symbol)
                        }
                    }
                    .listRowSeparator(.hidden)
                } header: {
                    Text("\(Image("basics")) BASICS")
                        .backgroundStyle(.secondary)
                }
                .listSectionSeparator(.visible, edges: .top)
            }
            .navigationDestination(for: HelpCellContent.self) {
                HelpCell(content: $0)
            }
            .listStyle(.plain)
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .environment(\.colorScheme, .light)
            .font(.body)
            .toolbar { DismissButton() }
            .gesture(dismissSwipe)
        }
        .transition(.move(edge: .leading))
        .tint(Color.label2)
    }
    
    private var basicsSection:some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Bubbles")
                    .font(.headline)
                Text("..are colorful stopwatches and timers. Bubbles store activity and [create events](eventify://saveActivity) in Calendar App. Bubbles easily [change](eventify://changeBubble) from stopwatch to timer or viceversa")
                    .foregroundStyle(.gray)
                HStack {
                    VStack {
                        Text("\(Image.stopwatch) Stopwatch")
                        Image("bubble.stopwatch")
                            .resizable()
                            .scaledToFit()
                    }
                    Divider()
                    VStack {
                        Text("\(Image.timer) Timer")
                        Image("bubble.timer")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(height: 130)
            }
            
            VStack(alignment: .leading) {
                Text("Gesture Areas")
                    .font(.headline)
                Text("Seconds area is always visible. Gestures will always work, regardless if an area is visible or hidden")
                    .foregroundStyle(.gray)
                Image("bubble.areas")
                    .resizable()
                    .scaledToFit()
            }
            
            VStack(alignment: .leading) {
                Text("Gestures")
                    .font(.headline)
                Text("\(Image(systemName: "circle.fill")) Tap, \(Image(systemName: "circle.circle.fill")) Touch and hold")
                    .foregroundStyle(.gray)
                Image("bubble.gestures")
                    .resizable()
                    .scaledToFit()
            }
        }
        .tint(.blue)
    }
    
    private func openYouTubeTutorial() {
        if let url = URL.watchTutorial {
            openURL(url)
        }
    }
    
    private func handleOpen(_ url:URL) {
        let receivedStringURL = url.absoluteString
        let content =
        HelpCellContent.all.filter { $0.title.description == receivedStringURL }.first
        
        if let content = content {
            SmallHelpOverlay.Model.shared.path.append(content)
        }
    }
    
    private func dismiss() {
        secretary.bigHelpOverlay(.hide)
    }
    
    //swipe left to dismiss
    private var dismissSwipe:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded {
                if $0.translation.width < -10 {
                    dismiss()
                }
            }
    }
    
    init?(_ show:Bool) {
        guard show else {
            return nil
        }
    }
}

extension BigHelpOverlay {
    struct DismissButton:View {
        @Environment(Secretary.self) private var secretary
        
        var body:some View {
            Button {
                secretary.bigHelpOverlay(.hide)
            } label: {
                Label("Dismiss", systemImage: "xmark")
            }
        }
    }
}


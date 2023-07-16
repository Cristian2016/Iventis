//
//  HelpViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.12.2023.
//

import SwiftUI

struct HelpViewHierarchy: View {
    @State private var path = NavigationPath()
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        if secretary.showHelpViewHierarchy {
            NavigationStack(path: $path) {
                ScrollViewReader { proxy in
                    List {
                        VStack {
                            Text("Bubble Types")
                                .foregroundStyle(.gray)
                                .font(.footnote)
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
                        
                        VStack {
                            Text("Touch Areas")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                            Text("Each bubble has 3 areas: hours, minutes, seconds. Seconds area is always visible")
                            Image("bubble.areas")
                                .resizable()
                                .scaledToFit()
                        }
                        
                        VStack {
                            Text("Supported Gestures")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                            Text("Tap, touch and hold, swipe")
                            Image("bubble.gestures")
                                .resizable()
                                .scaledToFit()
                            Image("bubble.swipe")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .listStyle(.plain)
                }
                .navigationTitle("Help")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .environment(\.colorScheme, .light)
                .font(.caption)
                .toolbar { dimissButton }
                .gesture(dismissSwipe)
            }
            .transition(.move(edge: .leading))
        }
    }
    
    private var dimissButton:some View {
        Button {
            dismiss()
        } label: {
            Label("Dismiss", systemImage: "xmark")
        }
        .tint(Color.label)
    }
    
    private func dismiss() {
        secretary.helpViewHiewHierarchy(.hide)
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
}

#Preview {
    HelpViewHierarchy()
        .environment(Secretary())
}

//
//  UnpinnedSection.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 25.01.2024.
//

import SwiftUI

struct PinnedSection:View {
    let bubbles:SectionedFetchResults<Bool, Bubble>.Element
    
    var body: some View {
        ForEach (bubbles) { bubble in
            ZStack {
                NavigationLink(value: bubble) { }.opacity(0)
                BubbleCell(bubble)
            }
            .listRowInsets(EdgeInsets()) //removes stupid list padding
            .id(String(bubble.rank))
        }
    }
}


struct UnpinnedSection: View {
    let bubbles:SectionedFetchResults<Bool, Bubble>.Element
    @Environment(Secretary.self) private var secretary
    
    private func imageName(for bubble:Bubble) -> String? {
        switch bubble.state {
            case .finished: return "checkmark"
            case .brandNew, .paused: return nil
            default: return nil
        }
    }
    
    var body: some View {
        let _ = secretary.refresh //⚠️
        if secretary.showFavoritesOnly {
            ScrollView(.horizontal) {
                LazyHStack {
                    Text("Show \(bubbles.count)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    ForEach(bubbles) { bubble in
                        Circle()
                            .fill(Color.bubbleColor(forName: bubble.color))
                            .frame(height: 26)
                            .overlay {
                                if let imageName = imageName(for: bubble) {
                                    Image(systemName: imageName)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .onTapGesture { secretary.showFavoritesOnly = false }
        }
        else {
            ForEach(bubbles) { bubble in
                ZStack {
                    NavigationLink(value: bubble) { }.opacity(0)
                    BubbleCell(bubble)
                }
                .listRowInsets(EdgeInsets()) //removes stupid list padding
                .id(String(bubble.rank))
            }
        }
    }
}

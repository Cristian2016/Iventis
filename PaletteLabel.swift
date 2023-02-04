//
//  PaletteLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.02.2023.
//

import SwiftUI

struct PaletteLabel<Content:View>: View {
    struct Content {
        
    }
    
    struct Metrics {
        let backgroundRadius = CGFloat(20)
    }
    
    init(@ViewBuilder _ content:() -> Content, action: @escaping () -> ()) {
        self.content = content()
        self.action = action
    }
    
    let content:Content
    let action:() -> ()
    let metrics = Metrics()
    
    var body: some View {
        VStack {
            content
            .allowsHitTesting(false)
            dismissButton
        }
        .padding()
        .padding([.top, .bottom])
        .background {
            RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                .fill(.thinMaterial)
                .standardShadow()
        }
    }
    
    // MARK: - Legos
    private var dismissButton:some View {
        Button { action() } label: { Text("OK. Don't show") }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

struct PaletteLabel_Previews: PreviewProvider {
    static var content:some View {
        VStack(alignment: .leading) {
            Text("\(Image(systemName:"hand.tap")) Tap Color for Stopwatch")
            Text("\(Image(systemName:"digitalcrown.horizontal.press")) Long Press for Timer")
            Text("\(Image(systemName:"arrow.left")) Swipe Left to Dismiss")
        }
    }
    static var previews: some View {
        PaletteLabel { content } action: { }
    }
}

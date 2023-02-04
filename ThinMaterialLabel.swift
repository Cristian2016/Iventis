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
            dismissButton
        }
        .padding()
        .background { roundedBackground }
        .frame(maxWidth: 300)
    }
    
    // MARK: - Legos
    private var dismissButton:some View {
        Button { action() } label: {
            Text("OK. Don't show")
                .frame(maxWidth: .infinity)
        }
        .tint(.red)
        
        .buttonStyle(.borderedProminent)
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.backgroundRadius)
            .fill(.thinMaterial)
            .standardShadow()
    }
    
    // MARK: -
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
        ThinMaterialLabel { content } action: { }
    }
}

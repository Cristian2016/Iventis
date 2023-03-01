//
//  EmptyBubbleListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 25.04.2022.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        VStack (alignment:.center, spacing: 20) {
            HStack {
                Text("Create Bubbles").font(.title)
                    .multilineTextAlignment(.center)
            }
            VStack (alignment:.leading, spacing: 15) {
                swipeRight
                tap
                tapHold
                
            }
        }
        .padding()
    }
    
    var swipeRight:some View {
        HStack (alignment:.top) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            VStack (alignment:.leading) {
                Text("Swipe right")
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.green)
                Text("on the Yellow Strip")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var tap:some View {
        HStack (alignment:.top) {
            Image(systemName: "circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            VStack (alignment:.leading) {
                HStack (alignment:.lastTextBaseline) {
                    Text("Tap")
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(.green)
                    Text("any Color")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("for Stopwatch")
                    Image(systemName: "stopwatch")
                }.foregroundColor(.secondary)
            }
        }
    }
    
    var tapHold:some View {
        HStack (alignment:.top) {
            ZStack {
                Image(systemName: "circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                Image(systemName: "clock.fill")
                    .font(.body)
                    .foregroundColor(.white)
                    .offset(x: 0, y: -5)
            }
            
            VStack (alignment:.leading) {
                Text("Tap & Hold")
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.green)
                HStack {
                    Text("for Timer")
                    Image(systemName: "timer")
                }.foregroundColor(.secondary)
            }
        }
    }
}

struct EmptyBubbleListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView()
    }
}

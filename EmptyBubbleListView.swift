//
//  EmptyBubbleListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 25.04.2022.
//

import SwiftUI

struct EmptyBubbleListView: View {
    var body: some View {
        VStack (alignment:.center, spacing: 10) {
            HStack {
                Text("How to\nCreate Bubbles").font(.title)
                    .multilineTextAlignment(.center)
            }
            VStack (alignment:.leading, spacing: 10) {
                HStack (alignment:.top) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    VStack (alignment:.leading) {
                        Text("Swipe right")
                            .font(.title)
                            .foregroundColor(.green)
                        Text("on the Yellow Strip")
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack (alignment:.leading) {
                    HStack (alignment:.top) {
                        Image(systemName: "circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        VStack (alignment:.leading) {
                            HStack (alignment:.lastTextBaseline) {
                                Text("Tap")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("any Colored Circle")
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("for Stopwatch")
                                Image(systemName: "stopwatch")
                            }.foregroundColor(.secondary)
                        }
                    }
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
                                .font(.title)
                                .foregroundColor(.green)
                            HStack {
                                Text("for Timer")
                                Image(systemName: "timer")
                            }.foregroundColor(.secondary)
                        }
                    }
                }
                
            }
            
        }
        .padding()
    }
}

struct EmptyBubbleListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyBubbleListView()
    }
}

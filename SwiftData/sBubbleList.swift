//
//  sBubbleList.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.12.2023.
//

import SwiftUI
import SwiftData
import MyPackage

struct sBubbleList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bubbles: [sBubble]
    @Query(animation: .bouncy) private var sessions: [sSession]
    
    var body: some View {
        List {
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(Color.bubbleColor(forName: bubble.color))
                    .overlay(Text(bubble.color).foregroundStyle(.white))
                    .frame(height: 50)
            }
            ForEach(sessions) { session in
                Rectangle()
                    .frame(height: 20)
            }
        }
        .onAppear {
//            let newBubble = sBubble(.stopwatch, color: "slateBlue")
//            modelContext.insert(newBubble)
            print(bubbles.map(\.color))
            
//            var sessions = [sSession]()
//            bubbles.forEach {
//                let session = sSession($0)
//                modelContext.insert(session)
//            }
//            bubbles.forEach { sBubble in
//                modelContext.delete(sBubble)
//            }
            
//            delayExecution(.now() + 4) {
//                bubbles.forEach { sBubble in
//                    modelContext.delete(sBubble)
//                }
//            }
        }
        .task {
            delayExecution(.now() + 4) {
//                createBubbles()
            }
        }
    }
    
    private func createBubbles() {
        let colors = ["red", "blue", "yellow", "orange", "magenta"]
        colors.forEach { color in
            let bubble = sBubble(.stopwatch, color: color)
//            let session = sSession(bubble)
            modelContext.insert(bubble)
//            modelContext.insert(session)
        }
    }
}

//#Preview {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            sBubble.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//        
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//    
//    sBubbleList()
//        .modelContainer(sharedModelContainer)
//}

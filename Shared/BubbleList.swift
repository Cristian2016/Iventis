//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//

import SwiftUI
import CoreData

struct BubbleList: View {
    //1
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: -
    @StateObject private var viewModel = ViewModel()
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [])
    private var bubbles:FetchedResults<Bubble>
    @State private var isActive = true
    @State var isBubbleDetailPresented = false
    
    // MARK: -
    static var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: -
    init() {
           UITableView.appearance().showsVerticalScrollIndicator = false
       }
    
    // MARK: -
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer(minLength: geo.safeAreaInsets.top) //distance from status bar
                List {
                    ForEach(bubbles) { BubbleCell($0, $isBubbleDetailPresented) }
                    .onDelete { delete($0) }
                    .listRowSeparator(.hidden)
                }.listStyle(.plain)
            }.ignoresSafeArea()
        }
        .onChange(of: scenePhase, perform: {
            switch $0 {
                case .active: viewModel.timer(.start)
                case .background: viewModel.timer(.pause)
                case .inactive: break
                default: break
            }
        })
        .navigationBarHidden(true)
        .onAppear {
//            viewModel.makeBubbles()
        }
        .sheet(isPresented: $isBubbleDetailPresented) {
            BubbleDetail()
        }
    }
}

// MARK: -
extension BubbleList {
    private func delete(_ indexSet:IndexSet) {
        indexSet.forEach {
            viewModel.delete(bubble: bubbles[$0])
        }
    }
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}


struct BubbleDetail:View {
    var body: some View {
        Text("Bubble Detail")
    }
}

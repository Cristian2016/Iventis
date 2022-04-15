//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//

import SwiftUI
import CoreData

struct BubbleList: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ViewModel()
    
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [])
    private var bubbles:FetchedResults<Bubble>
    
    init() {
           UITableView.appearance().showsVerticalScrollIndicator = false
       }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer(minLength: geo.safeAreaInsets.top) //distance from status bar
                List {
                    ForEach(bubbles) {bubble in
                        BubbleCell(bubble)
//                            .environmentObject(viewModel)
                    }
                    .onDelete { indices in
                        print("delete")
                    }
                    .listRowSeparator(.hidden)
                    
                    Text("New Bubble").frame(height: 120)
                } .listStyle(.plain)
            }
            .ignoresSafeArea()
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
    }
    
    // MARK: -
    static var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}

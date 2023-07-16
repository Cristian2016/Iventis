//
//  InfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.04.2023.
//

import SwiftUI
import MyPackage

struct InfoStore {
    struct Info:Identifiable, Hashable {
        var symbol:String?
        let name:String
        
        let id = UUID().uuidString
    }
    
    static let all = [
        Info(symbol: "questionmark.circle.fill", name: "Activity | Entry | Pair"),
        Info(symbol: "calendar", name: "Enable Calendar"),
        Info(symbol: "timer.circle.fill", name: "Create Timer"),
        Info(symbol: "trash", name: "Delete Bubble/Activity"),
        Info(symbol: "trash", name: "Delete Entry")
    ]
}

struct InfoViewHierarchy: View {
    @State private var path = [InfoStore.Info]()
    @State private var show = false
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        ZStack {
            if show {
                NavigationStack(path: $path) {
                    List {
                        ForEach(InfoCell.Input.all) { InfoCell(input: $0) }
                            .listSectionSeparator(.hidden)
                        
                        ForEach(InfoStore.all) { info in
                            NavigationLink(value: info) {
                                HStack {
                                    if let symbol = info.symbol { Image(systemName: symbol) }
                                    Text(info.name)
                                }
                            }
                        }
                        .navigationTitle("Info")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .navigationDestination(for: InfoStore.Info.self) {
                        InfoOutlineView(info: $0).toolbar { dismissButton }
                    }
                    .toolbar { dismissButton }
                }
            }
        }
    }
    
    // MARK: - Lego
    private var dismissButton:some View {
        Button("Dismiss") { dismiss() }
            .tint(.red)
    }
    
    // MARK: - Methods
    private func dismiss() {
        path = [] //empty navigation stack
    }
}

extension InfoViewHierarchy {
    
}

//struct InfoViewHierarchy_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoViewHierarchy()
//    }
//}

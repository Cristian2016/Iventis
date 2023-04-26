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
    
    static let infos = [
        Info(symbol: "calendar", name: "Enable Calendar"),
        Info(symbol: "timer", name: "Create Timer"),
        Info(symbol: "trash", name: "Delete Bubble/Activity"),
        Info(symbol: "trash", name: "Delete Entry"),
    ]
}

struct InfoViewHierarchy: View {
    @State private var path = [InfoStore.Info]()
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                NavigationStack(path: $path) {
                    List {
                        ForEach(InfoCell.Input.all) { InfoCell(input: $0) }
                        
                        ForEach(InfoStore.infos) { info in
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
        .onReceive(Secretary.shared.$showInfoVH) { output in
            if !output {
                withAnimation {
                    show = false
                }
            } else {
                handleOnReceive()
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
        Secretary.shared.showInfoVH = false
        path = [] //empty navigation stack
    }
    
    private func handleOnReceive() {
        switch Secretary.shared.topMostView {
            case .bubbleDeleteActionView:
                delayExecution(.now() + 0.1) {
                    path = [InfoStore.infos[2]]
                }
            default:
                break
        }
        show = true
    }
}

extension InfoViewHierarchy {
    
}

struct InfoViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        InfoViewHierarchy()
    }
}

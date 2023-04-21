//
//  InfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.04.2023.
//

import SwiftUI

struct InfoStore {
    struct Info:Identifiable, Hashable {
        let id = UUID().uuidString
        
        let name:String
    }
    
    static let infos = [
        Info(name: "Enable Calendar"),
        Info(name: "Create Timer"),
        Info(name: "Delete Bubble/Activity"),
        Info(name: "Delete Activity Item"),
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
                        VStack(alignment: .leading) {
                            HInfoLego(input: .bubbleSecondsArea, inverseColors: true)
                            Divider()
                            InfoLego(input: .bubbleYellowArea, inverseColors: true)
                            Divider()
                        }
                        .listRowSeparator(.hidden)
                        
                        ForEach(InfoStore.infos) { info in
                            NavigationLink(value: info) {
                                Text(info.name)
                            }
                        }
                        .navigationTitle("Info")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .navigationDestination(for: InfoStore.Info.self) { info in
                        BubbleDeleteButton.MoreInfo()
                            .toolbar {
                                dismissButton
                            }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button("Dismiss") { dismiss() }
                            .tint(.red)
                        }
                    }
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
    }
    
    private func handleOnReceive() {
        switch Secretary.shared.topMostView {
            case .bubbleDeleteActionView:
                path = [InfoStore.infos[2]]
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

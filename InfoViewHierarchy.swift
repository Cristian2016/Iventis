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
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                VStack(alignment: .leading, spacing: 0) {
                    Image("sec")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    InfoLego(input: .bubbleSecondsArea, inverseColors: true)
                    InfoLego(input: .bubbleYellowArea, inverseColors: true)
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
                Text(info.name)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Dismiss") {
                                print("Dismiss")
                            }
                            .tint(.red)
                        }
                    }
            }
        }
    }
}

extension InfoViewHierarchy {
    
}

struct InfoViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        InfoViewHierarchy()
    }
}

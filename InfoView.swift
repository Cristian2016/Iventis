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
        Info(name: "Delete Bubble"),
        Info(name: "Delete Bubble Session")
    ]
}

struct InfoView: View {
    @State private var path = [InfoStore.Info]()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(InfoStore.infos) { info in
                    NavigationLink(value: info) {
                        Text(info.name)
                    }
                }
            }
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

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}

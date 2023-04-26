//
//  InfoOutlineView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.04.2023.
//

import SwiftUI

struct InfoOutlineView: View {
    
    let navigationTitle:String
        
    init(info: InfoStore.Info) {
        
        self.navigationTitle = info.name
        
        switch info.name {
            case "Enable Calendar":
                self.outlines = [.enableCal1, .enableCal2, .enableCal3]
            case "Activity | Entry | Pair":
                self.outlines = [.aepActivityEntryPair, .aepActivity, .aepPair, .aepEntry]
            default:
                self.outlines = []
        }
    }
    
    let outlines:[InfoOutlineUnit.Input]
    
    var body: some View {
        List {
            ForEach(outlines) {
                InfoOutlineUnit($0)
            }
            .listSectionSeparator(.hidden)
        }
        .navigationTitle(Text(navigationTitle))
        .scrollIndicators(.hidden)
        .listStyle(.plain)
    }
}

struct InfoOutlineView_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutlineView(info: .init(name: "Enable Calendar"))
    }
}

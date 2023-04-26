//
//  InfoOutlineView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.04.2023.
//

import SwiftUI

struct InfoOutlineView: View {
        
    init(info: InfoStore.Info) {
        switch info.name {
            case "Enable Calendar":
                self.outlines = [.enableCal1, .enableCal2, .enableCal3]
            default:
                self.outlines = []
        }
    }
    
    let outlines:[InfoOutlineUnit.Input]
    
    var body: some View {
        List {
            ForEach(outlines) { InfoOutlineUnit($0) }
                .listSectionSeparator(.hidden)
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
    }
}

struct InfoOutlineView_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutlineView(info: .init(name: "Enable Calendar"))
    }
}

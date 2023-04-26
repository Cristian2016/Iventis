//
//  InfoOutlineView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.04.2023.
//

import SwiftUI

struct InfoOutlineView: View {
    
    let outlines:[InfoOutlineUnit.Input]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(outlines) {
                InfoOutlineUnit($0)
            }
        }
    }
}

struct InfoOutlineView_Previews: PreviewProvider {
    static var previews: some View {
        InfoOutlineView(outlines: [.enableCal1, .enableCal2, .enableCal3])
    }
}

//
//  SpecialScrollView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.12.2023.
//

import SwiftUI

struct SpecialScrollView: View {
    var body: some View {
        ScrollView {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .containerRelativeFrame(.vertical, alignment: .center)
        }
        .border(.red)
        .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    SpecialScrollView()
}

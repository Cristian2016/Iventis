//
//  DeleteView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.04.2023.
//

import SwiftUI

struct DeleteView: View {
    var body: some View {
        VStack {
            Text(Date().addingTimeInterval(-36780), style: .timer)
            Text(Date(), style: .relative)
        }
    }
}

struct DeleteView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteView()
    }
}

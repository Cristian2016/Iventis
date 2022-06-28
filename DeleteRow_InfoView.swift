//
//  DeleteRow_InfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.06.2022.
//

import SwiftUI

struct DeleteRow_InfoView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack (alignment: .leading) {
                Divider()
                    .frame(maxWidth: .infinity)
                Text("\(Image(systemName: "trash")) Delete Row")
                Text("\(Image(systemName: "arrow.backward.circle.fill")) Swipe Left")
                    .foregroundColor(.lightGray)
            }
            .fixedSize(horizontal: true, vertical: false)
            Spacer()
        }
    }
}

struct DeleteRow_InfoView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteRow_InfoView()
    }
}

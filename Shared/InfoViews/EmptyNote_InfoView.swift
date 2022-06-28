//
//  EmptyNote_InfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 28.06.2022.
//

import SwiftUI

struct EmptyNote_InfoView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyNote_InfoView()
    }
}

struct EmptyNote_InfoView: View {
    var body: some View {
        VStack (alignment: .leading) {
            Divider().frame(maxWidth: .infinity)
            Text("\(Image(systemName: "note")) Empty Notes")
            Text("Are Not Allowed").foregroundColor(.lightGray)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

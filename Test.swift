//
//  Test.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.05.2022.
//

import SwiftUI

struct Test: View {
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView (.horizontal) {
                HStack {
                    ForEach (0..<100) { index in
                        Rectangle()
                            .fill(index%2 == 0 ? Color.orange : .blue)
                            .frame(width: 200, height: 50)
                            .onTapGesture {
                                proxy.scrollTo(0)
                            }
                    }
                }
                
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}

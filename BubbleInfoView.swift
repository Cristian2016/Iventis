//
//  BubbleInfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.03.2023.
//

import SwiftUI

struct BubbleInfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("Sessions")
                     .thumbnail(200)
                     .overlay {
                         Text("7 Sessions")
                             .offset(y: -50)
                     }
                Image(systemName: "cup.and.saucer.fill")
                    .background {
                        Ellipse()
                            .fill(.black)
                            .padding(7)
                            .offset(y: -5)
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(.gray, .blue)
            }
        }
    }
}

struct BubbleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleInfoView()
    }
}

//
//  StartInfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.07.2022.
//

import SwiftUI

struct StartInfoView: View {
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                HStack (alignment: .lastTextBaseline) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 40))
                    Text("Tap")
                        .font(.system(size: 22).monospaced())
                        .fontWeight(.medium)
                }
                .foregroundStyle(.green)
                Image("cellTap")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Divider()
                
                HStack (alignment: .lastTextBaseline) {
                    Image(systemName: "2.circle.fill")
                        .font(.system(size: 40))
                    Text("Double Tap")
                        .font(.system(size: 22).monospaced())
                        .fontWeight(.medium)
                }
                .foregroundStyle(.green)
                Image("cellDoubleTap")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Divider()
                
                HStack (alignment: .lastTextBaseline) {
                    TapHold(fontSize: 30)
                    Text("Tap & Hold")
                        .foregroundStyle(.green)
                        .font(.system(size: 22).monospaced())
                        .fontWeight(.medium)
                }
                Image("cellTapHold")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .padding()
    }
}

struct StartInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StartInfoView()
    }
}

//
//  Schematics.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI
import MyPackage

struct FramePortrait: View {
    @State private var isPortrait = true
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "iphone")
                    .symbolRenderingMode(.monochrome)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fontWeight(.ultraLight)
                    .frame(width: 150)
//                    .foregroundColor(.lightGray)
                    .background {
                        Color.cyan
                            .cornerRadius(30)
                            .overlay {
                                Image(systemName: "2.circle.fill")
                                    .rotationEffect(.degrees(isPortrait ? 0 : -90))
                                    .offset(x: 56)
                            }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .padding()
                            .padding(6)
                            .frame(width: 130, height: 240)
                    }
                    .rotationEffect(.degrees(isPortrait ? 0 : 90))
               
                Image(systemName: "1.circle.fill")
            }
            
            VStack(alignment: .leading) {
                Text("\(Image(systemName: "1.circle.fill")) Inside frame")
                Text("\(Image(systemName: "2.circle.fill")) Outside frame")
                    .foregroundColor(.cyan)
            }
        }
        .onTapGesture {
            isPortrait.toggle()
        }
    }
}

struct FramePortrait_Previews: PreviewProvider {
    static var previews: some View {
        FramePortrait()
    }
}

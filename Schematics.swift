//
//  Schematics.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI
import MyPackage

struct Schematics: View {
    var body: some View {
        HStack {
            ZStack {
                Image(systemName: "iphone")
                    .symbolRenderingMode(.monochrome)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fontWeight(.ultraLight)
                    .frame(width: 150)
//                    .foregroundColor(.lightGray)
                    .background {
                        Color.yellow
                            .cornerRadius(30)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .padding()
                            .padding(6)
                            .frame(width: 130, height: 240)
                    }
                Image(systemName: "2.circle.fill")
                    .offset(x: 56)
                Image(systemName: "1.circle.fill")
            }
            
            VStack(alignment: .leading) {
                Text("\(Image(systemName: "1.circle.fill")) Inside frame")
                Text("\(Image(systemName: "2.circle.fill")) Outside frame")
            }
        }
    }
}

struct Schematics_Previews: PreviewProvider {
    static var previews: some View {
        Schematics()
    }
}

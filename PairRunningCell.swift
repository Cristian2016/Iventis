//
//  PairRunningCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.05.2022.
//

import SwiftUI

struct PairRunningCell: View {
    let edge = CGFloat(60)
    
    var body: some View {
        ZStack {
            //background
            HStack {
                Spacer()
                Circle()
                    .frame(width: edge, height: edge)
            }
            HStack {
                Spacer()
                Circle()
                    .frame(width: edge, height: edge)
                Spacer()
            }
            HStack {
                Circle()
                    .frame(width: edge, height: edge)
                Spacer()
            }
        
            //time components
            HStack {
                Spacer()
                Text("34")
                    .modifier(TimeComponents(edge: edge))
            }
            HStack {
                Spacer()
                Text("56")
                    .modifier(TimeComponents(edge: edge))
                Spacer()
            }
            HStack {
                Text("23")
                    .modifier(TimeComponents(edge: edge))
                Spacer()
            }
        }
        .frame(width: 160)
        .foregroundColor(.gray)
    }
    
    struct TimeComponents:ViewModifier {
        let edge:CGFloat
        
        func body(content: Content) -> some View {
            content
                .frame(width: edge, height: edge)
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
    }
}

struct PairRunningCell_Previews: PreviewProvider {
    static var previews: some View {
        PairRunningCell()
    }
}

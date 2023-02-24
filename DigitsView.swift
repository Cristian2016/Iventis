//
//  DigitsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.02.2023.
//

import SwiftUI
import MyPackage

struct DigitsView: View {
    var body: some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(.clear)
                .overlay {
                    HStack {
                        Text("12:")
                        Text("48:")
                        Text("59")
                    }
                    .padding(.top)
                    .padding(.top)
                    .padding(.top)
                    .fontWeight(.medium)
                }
                .font(.system(size: 80, design: .rounded))
                .foregroundColor(.black)
            
            HStack(spacing: 2) {
                vRoundedRectangle(corners: [.topLeft], radius: 0)
                    .fill(.yellow)
                    .overlay {
                    Text("7")
                            .font(.system(size: 60, design: .rounded))
                }
                Rectangle()
                    .fill(.yellow)
                    .overlay {
                    Text("8")
                            .font(.system(size: 60, design: .rounded))
                }
                vRoundedRectangle(corners: [.topRight], radius: 0)
                    .fill(.yellow)
                    .overlay {
                    Text("9")
                            .font(.system(size: 60, design: .rounded))
                }
            }
            HStack(spacing: 2) {
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("4")
                            .font(.system(size: 70, design: .rounded))
                }
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("5")
                            .font(.system(size: 70, design: .rounded))
                }
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("6")
                            .font(.system(size: 70, design: .rounded))
                }
            }
            HStack(spacing: 2) {
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("1")
                            .font(.system(size: 70, design: .rounded))
                }
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("2")
                            .font(.system(size: 70, design: .rounded))
                }
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("3")
                            .font(.system(size: 70, design: .rounded))
                }
            }
            HStack(spacing: 2) {
                vRoundedRectangle(corners: [.bottomLeft], radius: 30)
                    .fill(.yellow)
                Rectangle().fill(.yellow)
                    .overlay {
                    Text("0")
                            .font(.system(size: 70, design: .rounded))
                }
                vRoundedRectangle(corners: [.bottomRight], radius: 30)
                    .fill(.yellow)
            }
        }
        .foregroundColor(.white)
        .offset(x: 0, y: -24)
        .padding(4)
        .background {
            vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 50)
                .fill(Color.white)
                .standardShadow()
        }
        .padding(8)
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var digit:some View {
        Circle()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
            }
    }
}

struct DigitsView_Previews: PreviewProvider {
    static var previews: some View {
        DigitsView()
    }
}

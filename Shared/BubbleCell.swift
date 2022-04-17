//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
//

import SwiftUI

struct BubbleCell: View {
    @StateObject var bubble:Bubble
    @Binding var isBubbleDetailPresented:Bool
    
    init(_ bubble:Bubble, _ isBubbleDetailPresented:Binding<Bool>) {
        _bubble = StateObject(wrappedValue: bubble)
        _isBubbleDetailPresented = Binding(projectedValue: isBubbleDetailPresented)
    }
    
    static let dic:[CGFloat:CGFloat] = [ /* 12mini */728:140, /* 8 */667:150,  /* ipdo */568:125,  /* 13 pro max */926:163,  /* 13 pro */844:147,  /* 11 pro max */896:158, 812:140,  /* 8max */736:167]
    private let spacing:CGFloat = -30
    private let fontSize = Ratio.bubbleToFontSize * UIScreen.size.width * 0.85
    
    //⚠️ this property determines how many bubbles on screen to fit
    private static var edge:CGFloat = {
        print(UIScreen.main.bounds.height)
        return dic[UIScreen.main.bounds.height] ?? 140
    }()
    
    ///component padding
    private let padding = CGFloat(0)
    
    var body: some View {
        ZStack {
            ZStack {
                hoursComponent
                minutesComponent
            }
            .onTapGesture(count: 2, perform: {
                print("double tap")
            })
            .onTapGesture(count: 1) {
                isBubbleDetailPresented = true
            }
            
            secondsComponent
                .onTapGesture {
                    //start/pause bubble
                    print("tapped")
                }
        }
    }
    
    private var hoursComponent:some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: BubbleCell.edge, height: BubbleCell.edge)
                    .padding(padding)
                Text("28")
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    private var minutesComponent:some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .foregroundColor(.green)
                    .frame(width: BubbleCell.edge, height: BubbleCell.edge)
                    .padding(padding)
                Text("12")
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    private var secondsComponent:some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .foregroundColor(.orange)
                    .frame(width: BubbleCell.edge, height: BubbleCell.edge)
                    .padding(padding)
                Text("\(Int(bubble.fakeClock))")
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
        }
    }
    
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                print("Double tap")
            }
            .simultaneously(with: TapGesture(count: 1)
                                .onEnded {
                                    print("Single Tap")
                                })
    }
}

//struct BubbleCell1_Previews: PreviewProvider {
//    static var previews: some View {
//        BubbleCell(PersistenceController.preview.)
//    }
//}

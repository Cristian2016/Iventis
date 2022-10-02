//
//  TestView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.10.2022.
//

import SwiftUI

struct StartDelayInfoView: View {
    
    let gestureColor = Color.blue
    let gestureFont = Font.system(size: 40)
    let phoneFont = Font.system(size: 140).weight(.ultraLight)
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(Image.startDelay) Start Delay")
                .font(.system(size: 30))
            Text("*Start delay is not visible for running bubbles")
                .font(.footnote)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("\(Image.tap) Tap any digit combination").foregroundColor(.gray)
                
                digits
                    .font(.system(size: 70))
                    .foregroundColor(.lightGray)
                Divider()
                HStack {
                    Image(systemName: "iphone").font(phoneFont)
                        .foregroundColor(gestureColor)
                        .overlay { whiteTable }
                    VStack(alignment: .leading) {
                        Text("\(Image.save) Save Changes").fontWeight(.semibold)
                        Text("\(Image.tap) Tap anywhere outside table")
                            .foregroundColor(.gray)
                    }
                }
                Divider()
                Text("\(Image.remove) Remove Delay").fontWeight(.semibold)
                Text("\(Image.tapAndHold) Tap & Hold anywhere or")
                    .foregroundColor(.gray)
                Text("\(Image.swipeLeft) Swipe left from right screen edge")
                    .foregroundColor(.gray)
            }
            
            HStack {
                ZStack {
                    Image(systemName: "iphone")
                        .overlay {
                            Image.tapAndHold
                                .font(gestureFont)
                                .foregroundColor(gestureColor)
                        }
                }
                Image(systemName: "iphone")
                    .overlay {
                        Image.swipeLeft
                            .font(gestureFont)
                            .foregroundColor(gestureColor)
                            .offset(x: 20)
                    }
            }
            .font(phoneFont)
            .foregroundColor(.ultraLightGray)
        }
        .padding()
    }
    
    private var whiteTable:some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(.white)
            .frame(width: 50, height: 90)
    }
    
    private var digits:some View {
        HStack {
            Spacer()
            Image(systemName: "5.square.fill")
            Image(systemName: "10.square.fill")
                .overlay {
                    Image.tap
                      .foregroundColor(.blue)
                      .font(gestureFont)
                      .offset(x:16, y:16)
                }
            Image(systemName: "20.square.fill")
            Image(systemName: "45.square.fill")
            Spacer()
        }
        .fontWeight(.light)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        StartDelayInfoView()
    }
}

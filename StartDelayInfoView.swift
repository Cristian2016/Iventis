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
    let phoneFont = Font.system(size: 180).weight(.ultraLight)
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text("\(Image.startDelay) Start Delay")
                .font(.system(size: 30))
            Text("*Start delay unavailable for running bubbles")
                .font(.footnote)
                        
            VStack {
                VStack(alignment: .leading) {
                    Text("\(Image.checkmark) Set Delay").fontWeight(.semibold)
                    Text("\(Image.tap) Tap any digit combination").foregroundColor(.gray)
                }
                
                HStack {
                    Spacer()
                    Image.digits
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "iphone").font(phoneFont)
                        .foregroundColor(gestureColor)
                        .overlay { whiteTable }
                    VStack(alignment: .leading) {
                        Text("\(Image.save) Save").fontWeight(.semibold)
                        Text("\(Image.tap) Tap anywhere outside table")
                            .foregroundColor(.gray)
                    }
                   
                }
                
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("\(Image.delete) Delete").fontWeight(.semibold)
                        Text("\(Image.swipeLeft) Swipe left from right screen edge")
                            .foregroundColor(.gray)
                    }
                    Image(systemName: "iphone")
                        .overlay {
                            Image.swipeLeft
                                .font(gestureFont)
                                .foregroundColor(gestureColor)
                                .offset(x: 28)
                        }
                        .font(phoneFont)
                        .foregroundColor(.ultraLightGray)
                }
            }
        }
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

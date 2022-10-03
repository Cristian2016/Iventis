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
        VStack {
            Text("\(Image.startDelay) Start Delay")
                .font(.system(size: 34).weight(.medium))
                .foregroundColor(.black)
            
            VStack {
                Text("*Not available for running bubbles.")
                Text("Pause bubble first")
            }
            .font(.footnote)
            .foregroundColor(.gray)
            
            Divider()
                        
            VStack {
                VStack(alignment: .leading) {
                    Text("\(Image.checkmark) Set Delay")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("\(Image.tap) Tap any digit combination")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Spacer()
                    Image.digits
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .overlay {
                            Image.tap
                                .foregroundColor(gestureColor)
                                .offset(x: 34)
                                .font(.system(size: 40))
                        }
                    Spacer()
                }
                                
                HStack {
                    Image(systemName: "iphone")
                        .renderingMode(.original)
                        .font(phoneFont)
                        .background { blueBackground }
                        .overlay { whiteTable }
                        .foregroundColor(.black)
                    VStack(alignment: .leading) {
                        Text("\(Image.save) Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("\(Image.tap) Tap anywhere outside table")
                            .foregroundColor(.gray)
                    }
                    
                }
                
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("\(Image.delete) Delete")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("\(Image.swipeLeft) Swipe from screen edge")
                            .foregroundColor(.gray)
                    }
                    Image(systemName: "iphone")
                        .renderingMode(.original)
                        .foregroundColor(.black)
                        .overlay {
                            Image.swipeLeft
                                .font(gestureFont)
                                .foregroundColor(gestureColor)
                                .offset(x: 34)
                        }
                        .font(phoneFont)
                }
                .offset(y: -30)
            }
        }
    }
    
    private var whiteTable:some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(.white)
            .frame(width: 56, height: 100)
    }
    
    private var blueBackground:some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(gestureColor)
            .frame(width: 90, height: 164)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        StartDelayInfoView()
    }
}

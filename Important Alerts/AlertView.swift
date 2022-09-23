//
//  AlwaysOnDisplayAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//

import SwiftUI

struct AlertView<ImageContent:View, TextContent:View>: View {
    @AppStorage("displayAlwaysOnAlert") var displayAlwaysOnAlert = true
    
    init(@ViewBuilder _ title:() -> ImageContent,
         @ViewBuilder _ smallText:() -> TextContent,
         dismissAction: @escaping () -> ()) {
        
        self.dismissAction = dismissAction
        self.image = title()
        self.text = smallText() 
    }
    
    let image:ImageContent
    let text:TextContent
    let dismissAction:() -> ()
    
    var body: some View {
        ZStack {
            Color.alertScreenBackground
                .opacity(0.9)
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                    Spacer()
                }
                .foregroundColor(.yellow)
                .font(.system(size: 35))
                
                Color.clear.frame(height: 0)
                
                VStack (alignment: .leading, spacing: 4) {
                    image
                    text
                }
                
                Button {
                    neverDisplayAlertAgain()
                } label: {
                    HStack {
                        Spacer()
                        Label("Never Show Again", systemImage: "")
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.title3)
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            
            .padding()
            
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .standardShadow()
            }
            .padding()
            .padding()
        }
        .onTapGesture { dismissAction() }
        .ignoresSafeArea()
    }

    func neverDisplayAlertAgain() { displayAlwaysOnAlert = false }
}

struct AlwaysOnDisplayAlert_Previews: PreviewProvider {
    static var previews: some View {
        AlertView {
            Label("Always-On Display", systemImage: "sun.max.fill")
                .font(.system(size: 24).weight(.medium))
                .foregroundColor(.black)
        } _: {
            Text("This option drains the battery faster. Use only if needed. Do not forget to turn it off again")
                .foregroundColor(.gray)
        } dismissAction: {
            
        }
    }
}


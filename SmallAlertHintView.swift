//
//  SmallAlertHintView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.01.2023.
//

import SwiftUI

struct SmallAlertHintView: View {
    let alertContent:AlertHintContent
    
    var body: some View {
        ZStack {
            HStack(spacing: 10) {
                Image(systemName: alertContent.symbol ?? "")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                VStack(alignment: .leading) {
                        Text(alertContent.title)
                            .font(.callout)
                            .fontWeight(.medium)
                    
                    Text(alertContent.content ?? "")
                        .fontDesign(.monospaced)
                        .font(.caption) 
                }
                .foregroundColor(.black)
            }
            .padding(6)
            .background(.yellow)
            .frame(maxWidth: 400)
        }
    }
}

struct SmallAlertHintView_Previews: PreviewProvider {
    static var previews: some View {
        SmallAlertHintView(alertContent: AlertHint.scrollToTop)
    }
}

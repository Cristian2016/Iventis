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
            Color.white.opacity(0.9)
            HStack(spacing: 10) {
                Image(systemName: alertContent.symbol ?? "")
                    .foregroundColor(.yellow)
                    .font(.system(size: 30))
                VStack(alignment: .leading) {
                    HStack {
                        Text(alertContent.title)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    Text(alertContent.content ?? "")
                        .foregroundColor(.secondary)
                        .fontDesign(.monospaced)
                        .font(.caption)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1)
            )
            .frame(maxWidth: 320)
        }
    }
}

struct SmallAlertHintView_Previews: PreviewProvider {
    static var previews: some View {
        SmallAlertHintView(alertContent: .init(symbol: "info.circle.fill", title: "Scroll To Top?", content: "Scroll along left/right screen edge"))
    }
}

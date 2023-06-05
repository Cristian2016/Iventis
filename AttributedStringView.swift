//
//  AttributedStringView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 05.06.2023.
//

import SwiftUI

struct AttributedStringView: View {
    var attrString:AttributedString = {
        var attrString = AttributedString("Pula")
        attrString.font = .largeTitle.bold()
        attrString.strokeColor = .red
        attrString.backgroundColor = .yellow
        attrString.foregroundColor = .red
        attrString.underlineStyle = Text.LineStyle(pattern: .dashDotDot, color: .green)
        attrString.link = URL(string: "https://www.hackingwithswift.com")
        let interval = attrString.startIndex..<attrString.index(attrString.startIndex, offsetByCharacters: 1)
        attrString[interval].foregroundColor = .green
        return attrString
    }()
    
    var body: some View {
        Text(attrString)
    }
}

struct AttributedStringView_Previews: PreviewProvider {
    static var previews: some View {
        AttributedStringView()
    }
}

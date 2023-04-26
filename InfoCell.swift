//
//  InfoEntry.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.04.2023.
//

import SwiftUI

struct InfoCell: View {
    let input:Input
    
    var body: some View {
        switch input.kind {
            case .regular:
                VStack(alignment: .leading) {
                    if let overtitle = input.overtitle {
                        Text(overtitle)
                            .font(.system(size: 20).italic())
                            .foregroundColor(.secondary)
                    }
                    if !input.units.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(input.units) { InfoUnit($0) }
                        }
                    }
                    if let footnote = input.footnote {
                        Text(footnote)
                            .font(.caption2.italic())
                    }
                    if let imageName = input.image {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                }
            case .small:
                VStack {
                    HStack(alignment: .bottom) {
                        if !input.units.isEmpty {
                            VStack(alignment: .leading) {
                                if let overtitle = input.overtitle {
                                    Text(overtitle)
                                        .font(.system(size: 20).italic())
                                        .foregroundColor(.secondary)
                                }
                                ForEach(input.units) { InfoUnit($0) }
                            }
                        }
                        Spacer()
                        if let imageName = input.image {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 130)
                        }
                    }
                    if let footnote = input.footnote {
                        Text(footnote)
                            .font(.footnote.italic())
                            .foregroundColor(.secondary)
                    }
                }
            case .smallReversed:
                VStack {
                    HStack(alignment: .bottom) {
                        if let imageName = input.image {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 130)
                        }
                        
                        if !input.units.isEmpty {
                            VStack(alignment: .leading) {
                                if let overtitle = input.overtitle {
                                    Text(overtitle)
                                        .font(.system(size: 20).italic())
                                        .foregroundColor(.secondary)
                                }
                                ForEach(input.units) { InfoUnit($0) }
                            }
                        }
                    }
                    if let footnote = input.footnote {
                        Text(footnote)
                            .font(.footnote.italic())
                            .foregroundColor(.secondary)
                    }
                }
        }
    }
}

extension InfoCell {
    struct Input:Identifiable {
        var overtitle:LocalizedStringKey?
        var units:[InfoUnit.Input]
        var image:String?
        var footnote:LocalizedStringKey?
        var kind = Kind.regular
        let id = UUID().uuidString
        
        static let inputs:[Self] = [
            .init(units:[], image: "bubble.labels.hms"),
            .init(units: [.bubbleStart, .bubbleFinish], image: "bubble.s", kind: .small),
            .init(overtitle: "Use Yellow Area to", units: [.showActivity, .addNote], image: "bubble", kind: .regular)
        ]
    }
    
    enum Kind {
        case regular
        case small
        case smallReversed
    }
}

//struct InfoCell_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoCell(input: .sec, kind: .small)
//    }
//}

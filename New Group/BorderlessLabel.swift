//
//  BorderlessLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//

import SwiftUI

struct BorderlessLabel: View {
    let title:String
    var /* system */ symbol:String? = nil
    var color:Color? = .secondary
    
    var body: some View {
        let title = symbol != nil ?
        LocalizedStringKey("\(Image(systemName: symbol!)) \(title)") :
        LocalizedStringKey(title)
        
        Text(title)
            .foregroundStyle(color ?? .white)
            .animationDisabled()
    }
}

struct BorderlessLabel_Previews: PreviewProvider {
    static var previews: some View {
        BorderlessLabel(title: "pula", symbol: "eye", color: .orange)
    }
}

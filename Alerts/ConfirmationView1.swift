//
//  ConfirmationView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.01.2023.
//

import SwiftUI
import MyPackage

struct ConfirmationView1: View {
    let content:Content
    let dismissAction:() -> Void
    
    var body: some View {
        VStack {
            Text(content.title)
                .font(.system(size: 20).weight(.medium))
                .foregroundColor(.black)
            Label(content.title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(systemImageColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(radius: 1)
        )
    }
    
    // MARK: -
    private var systemImage:String {
        switch content.kind {
            case .removed: return "xmark"
            case .created: return "checkmark"
        }
    }
    private var systemImageColor:Color {
        switch content.kind {
            case .removed: return .red
            case .created: return .green
        }
    }
}

extension ConfirmationView1 {
    struct Content {
        let title:LocalizedStringKey
        let kind:Kind
        
        enum Kind {
            case created
            case removed
        }
        
        static let eventCreated = Content(title: "Calendar Event", kind: .created)
        static let eventRemoved = Content(title: "Calendar Event", kind: .removed)
    }
}

struct ConfirmationView1_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView1(content: .eventCreated, dismissAction: {})
    }
}

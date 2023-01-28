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
        VStack(spacing: 8) {
            Text(content.title)
            Divider().frame(width: 80)
            Label(name, systemImage: systemImage)
        }
        .font(.system(size: 30).weight(.medium))
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(fillColor)
                .shadow(radius: 2)
        )
        .allowsHitTesting(false)
    }
    
    // MARK: -
    private var systemImage:String {
        switch content.kind {
            case .removed: return "xmark"
            case .created: return "checkmark"
        }
    }
    private var fillColor:Color {
        switch content.kind {
            case .removed: return .red
            case .created: return .green
        }
    }
    
    private var name:String {
        switch content.kind {
            case .removed: return "Removed"
            case .created: return "Created"
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

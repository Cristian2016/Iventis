//
//  ConfirmationView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.01.2023.
//1 does not change! it remains always the same

import SwiftUI
import MyPackage

struct ConfirmView: View {
    struct Appearance {
        let cornerRadius = CGFloat(16)
        let backgroundColor = Color.deleteActionViewBackground
        let symbolFont = Font.system(size: 36).weight(.medium)
        let contentFont = Font.system(size: 24)
        let contentColor = Color.white
    } //1
    
    private let appearance = Appearance() //1
    let content:Content
    var dismissAction:(() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(appearance.symbolFont)
                .foregroundColor(fillColor)
            Text(content.title + "\n" + name)
                .font(appearance.contentFont)
        }
        .foregroundColor(appearance.contentColor)
        .padding()
        .padding([.top, .bottom])
        .background(
            RoundedRectangle(cornerRadius: appearance.cornerRadius)
                .fill(appearance.backgroundColor)
        )
        .allowsHitTesting(false)
    }
    
    // MARK: -
    private var systemImage:String {
        switch content.kind {
            case .removed, .off: return "xmark"
            case .created, .on: return "checkmark"
        }
    }
    private var name:String {
        switch content.kind {
            case .removed: return "Removed"
            case .created: return "Created"
            case .on: return "ON"
            case .off: return "OFF"
        }
    }
    
    // MARK: - Unused
    private var fillColor:Color {
        switch content.kind {
            case .removed, .off: return .red
            case .created, .on: return .vibrantGreen
        }
    }
}

extension ConfirmView {
    struct Content {
        let title:String
        let kind:Kind
        
        enum Kind {
            case created
            case removed
            case on
            case off
        }
        
        static let eventCreated = Content(title: "Calendar Event", kind: .created)
        static let eventRemoved = Content(title: "Calendar Event", kind: .removed)
        static let alwaysONDisplayON = Content(title: "Always-on Display", kind: .on)
        static let alwaysONDisplayOFF = Content(title: "Always-on Display", kind: .off)
    }
}

struct ConfirmationView1_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmView(content: .alwaysONDisplayON)
    }
}

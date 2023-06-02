//
//  ConfirmView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.06.2023.
//

import SwiftUI

struct CalendarConfirmation: View {
    private let metrics = Metrics() //1
    let content:Content
    var dismissAction:(() -> Void)? = nil
    
    var body: some View {
        VStack {
            Text(content.title)
                .font(metrics.contentFont)
            
            Label(name, systemImage: systemImage)
                .foregroundColor(fillColor)
                .font(.system(size: 26))
        }
        .padding()
        .padding(8)
        .allowsHitTesting(false)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: metrics.cornerRadius))
        .environment(\.colorScheme, .dark)
    }
    
    // MARK: -
    private var systemImage:String {
        switch content.kind {
            case .removed, .off: return "xmark"
            case .created, .on: return "checkmark"
            case .caffeinated: return "sun.max.fill"
            case .sleepy: return "moon.zzz.fill"
        }
    }
    
    private var name:String {
        switch content.kind {
            case .removed: return "Removed"
            case .created: return "Created"
            case .on: return "ON"
            case .off: return "OFF"
            case .caffeinated, .sleepy: return ""
        }
    }
    
    // MARK: - Unused
    private var fillColor:Color {
        switch content.kind {
            case .removed, .off: return .red
            case .created, .on: return .vibrantGreen
            case .caffeinated, .sleepy: return .label
        }
    }
}

extension CalendarConfirmation {
    struct Metrics {
        let cornerRadius = CGFloat(16)
        let backgroundColor = Color.deleteActionViewBackground
        let symbolFont = Font.system(size: 45)
        let contentFont = Font.system(size: 30)
        let contentColor = Color.white
    } //1
    
    struct Content {
        let title:LocalizedStringKey
        let kind:Kind
        
        enum Kind {
            case created
            case removed
            case on
            case off
            case caffeinated
            case sleepy
        }
        
        static let eventCreated = Content(title: "Calendar Event", kind: .created)
        static let eventRemoved = Content(title: "Calendar Event", kind: .removed)
    }
}

struct CalendarConfirmation_Previews: PreviewProvider {
    static var previews: some View {
        CalendarConfirmation(content: .eventRemoved)
    }
}

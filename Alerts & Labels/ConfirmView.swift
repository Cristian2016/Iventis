//
//  ConfirmationView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.01.2023.
//1 does not change! it remains always the same

import SwiftUI
import MyPackage

struct ConfirmView: View {
    struct Metrics {
        let cornerRadius = CGFloat(16)
        let backgroundColor = Color.deleteActionViewBackground
        let symbolFont = Font.system(size: 45)
        let contentFont = Font.system(size: 30)
        let contentColor = Color.white
    } //1
    
    private let metrics = Metrics() //1
    let content:Content
    var dismissAction:(() -> Void)? = nil
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(metrics.symbolFont)
                .foregroundColor(fillColor)
            VStack {
                Text(content.title)
                Text(name)
            }
            .font(metrics.contentFont)
        }
        .padding()
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: metrics.cornerRadius))
        .allowsHitTesting(false)
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

extension ConfirmView {
    struct Content {
        let title:String
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
        static let appCaffeinated = Content(title: "Screen Always-ON", kind: .caffeinated)
        static let appCanSleep = Content(title: "Screen Can Sleep", kind: .sleepy)
        static let startDelayCreated = Content(title: "Start Delay", kind: .created)
        static let startDelayRemoved = Content(title: "Start Delay", kind: .removed)
    }
}

struct ConfirmationView1_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmView(content: .eventCreated)
    }
}

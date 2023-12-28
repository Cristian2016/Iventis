//
//  DeepLink.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.12.2023.
//

import Foundation

enum HelpDeepLink:String {
    case enableCalendar = "Enable Calendar"
    case saveActivity = "Save Activity"
    case changeBubble = "Change Bubble"
    case tetherBubbleCal = "Tether Bubble-Calendar"
    case siriVoiceCommands = "Siri Voice Commands"
    case widgets = "Widgets"
    
    var description:String {
        switch self {
            case .enableCalendar:
                "fused://enableCalendar"
            case .changeBubble:
                "fused://changeBubble"
            case .tetherBubbleCal:
                "fused://tetherBubbleCal"
            case .siriVoiceCommands:
                "fused://siriVoiceCommands"
            case .widgets:
                "fused://widgets"
            case .saveActivity:
                "fused://saveActivity"
        }
    }
}

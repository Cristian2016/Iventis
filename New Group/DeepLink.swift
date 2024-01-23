//
//  DeepLink.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.12.2023.
//

import Foundation

enum HelpDeepLink:String {
    case enableCalendar = "Enable Calendar"
    case saveActivity = "Save to Calendar"
    case changeBubble = "Change Bubble"
    case tetherBubbleCal = "Tether Bubble to Calendar"
    case siriVoiceCommands = "Siri Voice Commands"
    case widgets = "Install Widgets"
    
    var description:String {
        switch self {
            case .enableCalendar:
                "eventify://enableCalendar"
            case .changeBubble:
                "eventify://changeBubble"
            case .tetherBubbleCal:
                "eventify://tetherBubbleCal"
            case .siriVoiceCommands:
                "eventify://siriVoiceCommands"
            case .widgets:
                "eventify://widgets"
            case .saveActivity:
                "eventify://saveActivity"
        }
    }
}

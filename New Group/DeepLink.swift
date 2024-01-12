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
    case changeBubble = "Change Tracker"
    case tetherBubbleCal = "Tether Tracker to Calendar"
    case siriVoiceCommands = "Siri Voice Commands"
    case widgets = "Lock Screen Widget"
    
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

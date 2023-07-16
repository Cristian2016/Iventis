//
//  nBubble.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.10.2023.
//

import SwiftData
import Foundation

@Model final class nBubble {
    let created = Date()
    
    var initialClock = TimeInterval(0)
    var currentClock = TimeInterval(0)
    
    var color:String
    var selectedTab:String?
    var note:String?
    var isNoteHidden = false
    var hasCalendar = false
    var hasWidget = false
    var isPinned = false

    var rank = UserDefaults.generate_nBubbleRank()
    
    @Relationship(deleteRule: .cascade) var nStartDelayBubble:nStartDelayBubble?
    @Relationship(deleteRule: .cascade, inverse: \nSession.nBubble) var nSessions = [nSession]()
    @Relationship(deleteRule: .cascade, inverse: \nHistory.nBubble) var nHistories = [nHistory]()
    
    init(_ kind:Kind, _ color:String) {
        switch kind {
            case .timer(let initialClock): 
                self.initialClock = initialClock
                self.currentClock = initialClock
            default: break
        }
        self.color = color
    }
}

extension nBubble {
    enum Kind:Codable {
        case stopwatch
        case timer(TimeInterval)
    }
}

extension UserDefaults {
    public static let  /* bubble */ nBubbleRank =  /* bubble */ "nBubbleRank"
    
    static func generate_nBubbleRank() -> Int {
        print(#function)
        
        let userDefaults = UserDefaults(suiteName: .appGroupName)!
        var rank = userDefaults.integer(forKey: UserDefaults.nBubbleRank)
        defer {
            rank += 1
            userDefaults.set(rank, forKey: UserDefaults.nBubbleRank)
        }
        return rank
    }
}

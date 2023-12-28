//
//  Bubble.swift
//  Fused1
//
//  Created by Cristian Lapusan on 31.12.2023.
//

import SwiftData
import Foundation

@Model
final class sBubble {
    let created = Date()
    
    var color:String
    
    var initialClock:Float
    var currentClock:Float
    var startDelay:Float?
    
    var isTimer:Bool {
        initialClock == 0 ? false :  true
    }
    
    var note:String?
    var isCalendarEnabled = false
    var isPinned = false
    var hasWidget = false
    
    //other objects
    @Relationship(deleteRule: .cascade , inverse: \sSession.bubble) var sessions = [sSession]()
    
    init(_ kind:Kind, color:String) {
        self.color = color
        
        switch kind {
            case .stopwatch:
                self.initialClock = 0
                self.currentClock = 0
            case .timer(let duration):
                self.initialClock = duration
                self.currentClock = duration
        }
        
        let session = sSession(self)
    }
    
    deinit {
        print("sBubble deinit")
    }
}

extension sBubble {
    enum Kind {
        case stopwatch
        case timer(duration:Float)
    }
}



//
//  sSession.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.12.2023.
//

import SwiftData
import Foundation

@Model
final class sSession {
    let created = Date()
    
    var started:Date?
    var ended:Date?
    
    var duration = Float(0)
    
    var bubble:sBubble
    @Relationship(deleteRule: .cascade , inverse: \sLap.session) var sessions = [sLap]()
    
    init(_ bubble:sBubble) {
        self.bubble = bubble
    }
    
    deinit {
        print("sSession deinit")
    }
}

@Model
final class sLap {
    let created = Date()
    
    var started:Date?
    var ended:Date?
    
    var duration = Float(0)
    
    var session:sSession
    
    init(_ session:sSession) {
        self.session = session
    }
    
    deinit {
        print("sLap deinit")
    }
}

//
//  nSession.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.10.2023.
//

import SwiftData
import Foundation

@Model final class nSession {
    let created = Date()
    
    var nBubble:nBubble?
    
    init() {
        
    }
}

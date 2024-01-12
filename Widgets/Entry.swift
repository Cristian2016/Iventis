//
//  Entry.swift
//  Eventify
//
//  Created by Cristian Lapusan on 18.01.2024.
//

import Foundation
import WidgetKit

struct Entry: TimelineEntry {
    let date: Date
    var input:Input?
    
    struct Input {
        let isRunning:Bool
        let startValue:TimeInterval
        let isTimer:Bool
    }
}

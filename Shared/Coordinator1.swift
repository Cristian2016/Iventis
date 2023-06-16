//
//  Coordinator1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.06.2023.
//

import Foundation
import Observation

@Observable
class BubbleCellCoordinator1 {
    weak private(set) var bubble:Bubble? = nil
    
    init(bubble: Bubble?) {
        self.bubble = bubble
    }
    
    // MARK: - Publishers
    var components = Components("-1", "-1", "-1", "-1")
}

extension BubbleCellCoordinator1 {
    struct Components {
        var hr:String
        var min:String
        var sec:String
        var hundredths:String
        
        init(_ hr:String, _ min:String, _ sec:String, _ hundredths:String) {
            self.hr = hr
            self.min = min
            self.sec = sec
            self.hundredths = hundredths
        }
    }
}

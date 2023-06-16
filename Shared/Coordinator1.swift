//
//  Coordinator1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.06.2023.
//Publishers:
//time components [hr, min, sec, hundredths]
//time components opacity
//bubbleCell color. it's a String for the only reason to respect the MVVM rules. Models do not have UI properties. Color is a UI property, not a model property
//timer progress [from 0.00 to 1.00]. valid for timers only

import Observation
import Foundation

@Observable
class BubbleCellCoordinator1 {
    weak private(set) var bubble:Bubble? = nil
    
    init(bubble: Bubble?) {
        self.bubble = bubble
    }
    
    // MARK: - Publishers
    var components = Components(hr: "-1", min: "-1", sec: "-1", hundredths: "-1")
    var opacity = Opacity()
    var color:String? { bubble?.color }
    var progress = "0.00"
    
    // MARK: -
}

extension BubbleCellCoordinator1 {
    
    ///Time componets displayed by the BubbleCell: Hours, Minutes, Seconds, Hundredths
    struct Components {
        var hr:String
        var min:String
        var sec:String
        var hundredths:String
    }
    
    ///Time Components Opacity. Hours and Minutes are not always visible
    struct Opacity {
        var hr = CGFloat(0)
        var min = CGFloat(0)
        
        mutating func updateOpacity(_ value:Float) {
            min = value > 59 ? 1 : 0.001
            hr = value > 3599 ?  1 : 0.001
        }
    }
}

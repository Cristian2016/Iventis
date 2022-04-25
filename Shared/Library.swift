//
//  Library.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
//

import UIKit
import SwiftUI

extension NSNotification.Name {
    static let valueUpdated = NSNotification.Name("valueUpdated")
    static let appLaunched = NSNotification.Name("appLaunched")
}

struct Ratio {
    //BubbleCell
    ///screen width to bubble width |<-|<------->|->|
    static let screenToBubbleWidth = CGFloat(0.924)
    static var bubbleToFontSize:CGFloat = { (screenToBubbleWidth / 3) * 0.55 }()
    static var bubbleComponentSpacerLength:CGFloat = { CGFloat(UIScreen.size.width * 0.309) }()
    
    //
}

extension UIScreen {
    static let size = UIScreen.main.bounds.size
}

extension NumberFormatter {
    //truncates Float and returns a string
    static func bubblesStyle(_ float:Float, fractionDigits:Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        //formatter.numberStyle = .ordinal //5th, 1st etc
        formatter.maximumFractionDigits = fractionDigits
        
        guard let string = formatter.string(from: NSNumber(value: float))
        else { fatalError() }
        return string
    }
}

extension String {
    static let appGroupName = "group.com.Timers.container"
}

extension FileManager {
    static var sharedContainerURL:URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: String.appGroupName)
        else { fatalError() }
        return url
    }()
}

extension Float {
    //converts currentClock to time components to display
    func timeComponents() -> (hr:Int, min:Int, sec:Int) {
        rounded(.toNearestOrEven) //discard all decimals
        let roundedClock = Int(rounded(.toNearestOrEven))
        
        //how many full hours
        let hr = roundedClock/3600
        //hours remaining
        let hrRemaining = roundedClock%3600
        
        //how many full minutes
        let min = hrRemaining/60
        //remaining
        let sec = hrRemaining%60
        
        return (hr, min, sec)
    }
}

extension UserDefaults {
    struct Key {
        static let rank = "rank"
    }
    
    static let shared = UserDefaults(suiteName: String.appGroupName)!
    
    static func assignRank() -> Int {
        //check if ranks exists
        let ud = UserDefaults.shared
        var rank = ud.integer(forKey: UserDefaults.Key.rank)
        defer {
            rank += 1
            ud.set(rank, forKey: UserDefaults.Key.rank)
        }
        return rank
    }
}

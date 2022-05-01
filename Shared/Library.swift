//
//  Library.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
//

#if !os(macOS)
import UIKit
#endif
import SwiftUI

extension Color {
    static let label = Color("label")
    static let detailViewBackground = Color("detailViewBackground")
    static let lightGray = Color("lightGray")
    static let calendar = Color("calendar")
    static let calendarOff = Color("calendarOff")
    static let background1 = Color("background1")
}

extension Image {
    static let trash = Image(systemName: "trash")
    static let pauseSticker = Image("pauseSticker")
    static let spotlight = Image("spotlight")
}

func delayExecution(_ delay:DispatchTime, code:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: delay, execute: code)
}

extension NSNotification.Name {
    static let backgroundTimerSignalReceived = NSNotification.Name("backgroundTimerSignalReceived")
    static let appLaunched = NSNotification.Name("appLaunched")
    static let bubbleRank =  NSNotification.Name("bubbleIDNotification")
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

public struct UserFeedback {
    public enum Kind {
        case haptic
        case sound
        case visual
    }
    
    public static func triggerSingleHaptic(_ style:UIImpactFeedbackGenerator.FeedbackStyle) {
        let haptic = UIImpactFeedbackGenerator(style: style)
        haptic.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            haptic.impactOccurred()
        }
    }
    
    public static func triggerDoubleHaptic(_ style:UIImpactFeedbackGenerator.FeedbackStyle) {
        UserFeedback.triggerSingleHaptic(style)
        
        let second = UIImpactFeedbackGenerator(style: .heavy)
        second.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            second.impactOccurred()
        }
    }
}

extension NumberFormatter {
    static let bubbleStyle:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.maximumIntegerDigits = 0
        return formatter
    }()
}

extension Float {
    var hundredthsFromCurrentClock:String {
        var string = NumberFormatter.bubbleStyle.string(from: NSNumber(value: self))!
        string.removeFirst()
        return string
    }
}

extension DateComponentsFormatter {
    static let bubbleStyle:DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
//        formatter.collapsesLargestUnit = true
        return formatter
    }()
}

extension DateFormatter {
    func  bubbleStyle(_ date:Date) -> String {
        
        locale = Locale(identifier: "ro_RO")
        dateStyle = .full
        timeStyle = .medium
        calendar = Calendar(identifier:.gregorian)
        weekdaySymbols =  ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        monthSymbols = ["Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.", "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec"]
        let result = string(from: date)
        
        return result
    }
}

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

extension UIDevice {
    static let isIPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

enum Visibility:CaseIterable {
    case visible
    case invisible //hidden. still part of VH
}

extension View {
    @ViewBuilder
    func visibility(_ visibility:Visibility) -> some View {
        switch visibility {
            case .visible: self
            case .invisible: self.hidden()
        }
    }
}

///various constants and values
struct Global {
    static let longPressLatency = Double(0.65) //seconds
    
    //bubbleCell size
    static let dic:[CGFloat:CGFloat] = [ /* 12mini */728:140, /* 8 */667:150,  /* ipdo */568:125,  /* 13 pro max */926:150,  /* 13 pro */844:147,  /* 11 pro max */896:150, 812:130,  /* 8max */736:167]
    
    static let circleDiameter:CGFloat = {
        print(UIScreen.main.bounds.height)
        return dic[UIScreen.size.height] ?? 140
    }()
}

extension Array {
    func shifted(by amount:Int) -> Array {
        
        if amount < 0 { fatalError("can't be negative. only zero or greater") }
        if amount == 0 { return self }
    
       let shiftedIndices = indices.map { index in
           (index + amount)%self.indices.count
        }
        
        var shiftedArray = [Element]()
        
        shiftedIndices.forEach { shiftedArray.append(self[$0]) }
        
        return shiftedArray
    }
}

extension Color {
    static let selectionGray = Color("selectionGray")
    static let label = Color("label")
    static let detailViewBackground = Color("detailViewBackground")
    static let lightGray = Color("lightGray")
    static let calendar = Color("calendar")
    static let calendarOff = Color("calendarOff")
    static let background1 = Color("background1")
    
    static let colorNames = ["sourCherry":"Sour Cherry",
                             "mint" : "Mint",
                             "slateBlue" : "Slate Blue",
                             "silver" : "Silver",
                             "ultramarine" : "Ultramarine",
                             "lemon" : "Lemon",
                             "red" : "Red",
                             "sky" : "Sky",
                             "bubbleGum" : "Bubble Gum",
                             "green" : "Green",
                             "charcoal" : "Charcoal",
                             "magenta" : "Magenta",
                             "purple" : "Purple",
                             "orange" : "Orange",
                             "chocolate" : "Chocolate",
                             "aqua" : "Aqua",
                             "byzantium" : "Byzantium",
                             "rose" : "Rose"]
    
    static func userFriendlyBubbleColorName(for bubbleColorName:String?) -> String {
        guard
            let bubbleColorName = bubbleColorName,
            let colorName = colorNames[bubbleColorName]
        else { fatalError() }
        
        return colorName
    }
}

extension Image {
    static let trash = Image(systemName: "trash")
    static let pauseSticker = Image("pauseSticker")
    static let spotlight = Image("spotlight")
    static let eyeSlash = Image(systemName: "eye.slash.fill")
}

func delayExecution(_ delay:DispatchTime, code:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: delay, execute: code)
}

extension NSNotification.Name {
    static let timerSignal = NSNotification.Name("backgroundTimerSignalReceived")
    static let appLaunched = NSNotification.Name("appLaunched")
    static let bubbleRank =  NSNotification.Name("bubbleIDNotification")
    static let topCellTapped = NSNotification.Name("topCellTapped")
    
    static let deleteBubbleRequest = NSNotification.Name("deleteBubbleRequest")
    static let resetBubbleRequest = NSNotification.Name("resetBubbleRequest")
    static let selectedTab = NSNotification.Name("selectedTab")
    
    static let textLimitExceeded = NSNotification.Name("textLimitExceeded")
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
    
    static let smallestEmojiValue = 127744
    static let emptySpaceValue = 32
}

extension FileManager {
    static var sharedContainerURL:URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: String.appGroupName)
        else { fatalError() }
        return url
    }()
}

extension String {
    ///if user enters "Gym ", it will be corrected to "Gym"
    mutating func trimWhiteSpaceAtTheEnd() {
        while last == " " { removeLast() }
    }
    mutating func trimWhiteSpaceAtTheBeginning() {
        while first == " " { removeFirst() }
    }
    
    mutating func removeWhiteSpaceAtBothEnds() {
        trimWhiteSpaceAtTheBeginning()
        trimWhiteSpaceAtTheEnd()
    }
    
    ///empty string: ""
    static let empty = ""
    
    static let space = " "
    
    var containsEmoji:Bool {
        var result = false
        
    loop: for scalar in unicodeScalars {
        if scalar.properties.isEmoji {
            result = true
            break loop
        }
    }
        return result
    }
}


extension Float {
    //converts currentClock to time components to display
    var timeComponents:TimeComponents {
        let decimalValue = Int(self) //used to compute hr. min, sec
        let fractionalValue = Int((self - Float(decimalValue))*100)
        
        //how many full hours
        let hr = decimalValue/3600
        //hours remaining
        let hrRemaining = decimalValue%3600
        
        //how many full minutes
        let min = hrRemaining/60
        //remaining
        let sec = hrRemaining%60
        
        return TimeComponents(hr: hr, min: min, sec: sec, cents: fractionalValue)
    }
    
    var timeComponentsAsStrings:TimeComponentsAsStrings {
        let components = timeComponents
        
        let cents = String(format: "%.2d", components.cents)
        return TimeComponentsAsStrings(hr: String(components.hr), min: String(components.min), sec: String(components.sec), cents: cents)
    }
    
    var timeComponentsAbreviatedString:String {
        let components = self.timeComponentsAsStrings
        
        let hr = (components.hr != "0") ? components.hr + "h" : ""
        let min = (components.min != "0") ? components.min + "m" : ""
        let cents = components.cents
        let sec = components.sec + "." + cents + "s"
        var result = hr + " " + min + " " + sec
        result.trimWhiteSpaceAtTheBeginning()
        return result
    }
    
    struct TimeComponents {
        let hr:Int
        let min:Int
        let sec:Int
        let cents:Int
    }
    
    struct TimeComponentsAsStrings:Encodable, Decodable {
        let hr:String
        let min:String
        let sec:String
        let cents:String
    }
}

extension UserDefaults {
    struct Key {
        ///bubble rank
        static let  /* bubble */ rank =  /* bubble */ "rank"
        
        static let localNotificationsAuthorizationRequestedAlready = "localNotificationsAuthorizationRequestedAlready"
        static let calendarAuthorizationRequestedAlready = "calendarAuthorizationRequestedAlready"
        static let defaultCalendarIdentifier = "defaultCalendarIdentifier"
        
        static let notificationReceivalMoment = "notificationReceivalMoment"
        static let infoBannerNotShownAlready = "infoBannerNotShownAlready"
        
        static let widgetEnabledTimeBubble = "widgetEnabledTimeBubble"
        static let shouldExplainingTextBeVisible = "shouldExplainingTextBeVisible"
        
        static let firstAppLaunchEver = "firstAppLaunchEver"
    }
    
    static func generateRank() -> Int {
        //get rank
        //increase rank by one
        //save rank
        let ud = UserDefaults(suiteName: String.appGroupName)!
        var rank = ud.integer(forKey: UserDefaults.Key.rank)
        defer {
            rank += 1
            ud.set(rank, forKey: UserDefaults.Key.rank)
        }
        return rank
    }
    
    static func resetRankGenerator(_ value:Int) {
        let ud = UserDefaults(suiteName: String.appGroupName)!
        ud.set(value, forKey: UserDefaults.Key.rank)
    }
    
    static let shared = UserDefaults(suiteName: "group.com.Timers.container")!
}

public struct UserFeedback {
    public enum Kind {
        case haptic
        case sound
        case visual
    }
    
    public static func singleHaptic(_ style:UIImpactFeedbackGenerator.FeedbackStyle) {
        let haptic = UIImpactFeedbackGenerator(style: style)
        haptic.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            haptic.impactOccurred()
        }
    }
    
    public static func doubleHaptic(_ style:UIImpactFeedbackGenerator.FeedbackStyle) {
        UserFeedback.singleHaptic(style)
        
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
    ///Time Bubbles date style: Tue, 15 Feb. 22
    static let bubbleStyleDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "us_US")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "E, d MMM. yy"
        
        return dateFormatter
    }()
    
    static let bubbleStyleShortDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "us_US")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "E d"
        
        return dateFormatter
    }()
    
    ///Time Bubbles time style: 17:39:25
    static let bubbleStyleTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }()
}

extension Animation {
    static let secondsTapped = Animation.spring(response: 0.3, dampingFraction: 0.4)
    static let secondsLongPressed = Animation.spring(response: 0.2, dampingFraction: 0.6)
}

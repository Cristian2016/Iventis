//
//  Library.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.01.2023.
//

import SwiftUI

struct vRoundedRectangle: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        path.close()
        return Path(path.cgPath)
    }
}

extension Notification.Name {
    static let fiveSecondsSignal = Notification.Name("fiveSecondsSignal")
} //1 ViewModel 1//

extension UserDefaults {
    static let shared = UserDefaults(suiteName: .appGroupName)!
}

public extension Image {
    static let tap = Image(systemName:"hand.tap")
    static let longPress = Image(systemName:"digitalcrown.horizontal.press")
    static let leftSwipe = Image(systemName:"arrow.left.circle.fill")
}

public extension URL {
    static var sharedContainerURL:URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: .appGroupName)
        else { fatalError() }
        return url
    }()
}

public extension Color {
    static let deleteActionViewBackground = Color("deleteActionViewBackground")
    static let vibrantGreen = Color("vibrantGreen")
    ///secondary light mode, white dark mode
    static let secondaryWhite = Color("secondaryWhite")
    static let pauseStickerColor = Color("pauseStickerColor")
    static let pauseStickerFontColor = Color("pauseStickerFontColor")
}

public extension String {
    static let appGroupName = "group.com.Fused.container"
}

extension UserDefaults {
    static func generateRank() -> Int {
        //get rank
        //increase rank by one
        //save rank
        let ud = UserDefaults(suiteName: .appGroupName)!
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
}

public extension UserInterfaceSizeClass {
    var isRegular:Bool { self == .regular ? true : false }
}

///various constants and values
public struct Global {
    static let longPressLatency = Double(0.3) //seconds
    
    struct FontSize {
        static let help = CGFloat(30)
    }
}

public extension Float {
    //converts currentClock to time components to display
    var timeComponents:TimeComponents {
        if self == 0 { return .zeroAll }
        
        let decimalValue = Int(self) //used to compute hr. min, sec
//        let fractionalValue = Int((self - Float(decimalValue))*100)
        let fractionalValue = Int(((self - Float(Int(self))) * 100).rounded(.toNearestOrEven))
        
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
    
    var hundredths:Int {
        Int(((self - Float(Int(self))) * 100).rounded(.toNearestOrEven))
    }
    
    var timeComponentsAsStrings:TimeComponentsAsStrings {
        if self == 0 { return .zeroAll }
        
        let components = timeComponents
        
        let cents = String(format: "%.2d", components.cents)
        return TimeComponentsAsStrings(hr: String(components.hr),
                                       min: String(components.min),
                                       sec: String(components.sec),
                                       cents: cents)
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
        
        static let zeroAll = TimeComponents(hr: 0, min: 0, sec: 0, cents: 0)
    }
    
    struct TimeComponentsAsStrings:Encodable, Decodable {
        let hr:String
        let min:String
        let sec:String
        let cents:String
        
        static let zeroAll = TimeComponentsAsStrings.init(hr: "0", min: "0", sec: "0", cents: "00")
    }
}

extension Notification.Name {
    static let sizeNotification = Notification.Name("sizeNotification")
    static let frameNotification = Notification.Name("frameNotification")
}

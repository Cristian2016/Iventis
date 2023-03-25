//
//  Library.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.01.2023.
//1 The LongPressGesture can be done by long-pressing which prompts an action. By default, the LongPressGesture is activated after half a second and you may even choose to change the duration (seconds)

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

extension CharacterSet {
    static let allDigits = CharacterSet(charactersIn: "0123456789*")
}

extension Notification.Name {
    static let fiveSecondsSignal = Notification.Name("fiveSecondsSignal")
    static let detailViewVisible = Notification.Name("detailViewVisible")
    static let needleTracksLatestSession = Notification.Name("needleTracksLatestSession")
    static let doNotLetNeedleJump = Notification.Name("doNotLetNeedleJump")
    static let sizeNotification = Notification.Name("sizeNotification")
    static let frameNotification = Notification.Name("frameNotification")
    static let didBecomeActive = UIApplication.didBecomeActiveNotification
    
    ///kill StartSelayBubble  since sdb.state is now .finished
    static let killSDB = Notification.Name("killSDB")
    
    static let createTimer = Notification.Name("createTimer")
} //1 ViewModel

extension Notification {
    static let doNotLetNeedleJump = Notification.init(name: .doNotLetNeedleJump)
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: .appGroupName)!
}

public extension Image {
    static let tap = Image(systemName:"hand.tap")
    static let longPress = Image(systemName:"target")
    static let leftSwipe = Image(systemName:"arrow.left.circle.fill")
    static let rightSwipe = Image(systemName:"arrow.right.circle.fill")
    static let scrollToTop = Image(systemName: "arrow.up.to.line.compact")
    static let greaterThan = Image(systemName: "greaterthan.circle.fill")
    static let info = Image(systemName: "info.circle.fill")
    static let alert = Image(systemName: "exclamationmark.triangle.fill")
    static let roundCheckmark = Image(systemName: "checkmark.circle.fill")
    static let timer = Image(systemName: "timer")
    static let more = Image(systemName: "ellipsis.circle.fill")
    
    // MARK: - Info Assets
    static let dpv = Image("DurationPicker")
    static let moreOptionsView = Image("MoreOptions")
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
    static let topDetailViewBackground = Color("topDetailViewBackground")
    static let topDetailViewBackground1 = Color("topDetailViewBackground1")
    static let infoButtonColor = Color("infoButtonColor")
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
    static let longPressLatency = Double(0.65) //1
    
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
        var fractionalValue = Int(((self - Float(decimalValue)) * 100).rounded(.toNearestOrEven))
        
        var addedToSec = 0
        if fractionalValue == 100 {
            fractionalValue = 0
            addedToSec = 1
        }
        
        //how many full hours
        let hr = decimalValue/3600
        //hours remaining
        let hrRemaining = decimalValue%3600
        
        //how many full minutes
        let min = hrRemaining/60
        //remaining
        let sec = hrRemaining%60 + addedToSec
        
        return TimeComponents(hr: hr, min: min, sec: sec, hundredths: fractionalValue)
    }
    
    var hundredths:Int {
        Int(((self - Float(Int(self))) * 100).rounded(.toNearestOrEven))
    }
    
    var timeComponentsAsStrings:TimeComponentsAsStrings {
        if self == 0 { return .zeroAll }
        
        let components = timeComponents
        
        let hundredths = String(format: "%.2d", components.hundredths)
        return TimeComponentsAsStrings(hr: String(components.hr),
                                       min: String(components.min),
                                       sec: String(components.sec),
                                       hundredths: hundredths)
    }
    
    var timeComponentsAbreviatedString:String {
        let components = self.timeComponentsAsStrings
        
        let hr = (components.hr != "0") ? components.hr + "h" : ""
        let min = (components.min != "0") ? components.min + "m" : ""
        let hundredths = components.hundredths
        let sec = components.sec + "." + hundredths + "s"
        var result = hr + " " + min + " " + sec
        result.trimWhiteSpaceAtTheBeginning()
        return result
    }
    
    var timerTitle:String {
        let components = self.timeComponentsAsStrings
        
        let hr = (components.hr != "0") ? components.hr + "h" : ""
        let min = (components.min != "0") ? components.min + "m" : ""
        let sec = components.sec != "0" ? components.sec + "s" : ""
        var result = hr + " " + min + " " + sec
        result.trimWhiteSpaceAtTheBeginning()
        return result
    }
    
    struct TimeComponents {
        let hr:Int
        let min:Int
        let sec:Int
        let hundredths:Int
        
        static let zeroAll = TimeComponents(hr: 0, min: 0, sec: 0, hundredths: 0)
    }
    
    struct TimeComponentsAsStrings:Encodable, Decodable, Equatable {
        let hr:String
        let min:String
        let sec:String
        let hundredths:String
        
        static let zeroAll = TimeComponentsAsStrings.init(hr: "0", min: "0", sec: "0", hundredths: "00")
    }
}

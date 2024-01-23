//
//  Library.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.01.2023.
//1 The LongPressGesture can be done by long-pressing which prompts an action. By default, the LongPressGesture is activated after half a second and you may even choose to change the duration (seconds)

import SwiftUI

//MARK: - GLOBAL
func execute(after seconds:TimeInterval, mainQueue:Bool = true, code: @escaping ()->()) {
    
    if mainQueue {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: code)
    } else {
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds, execute: code)
    }
}

func reportBlue(_ bubble:Bubble, _ text:String) {
    if bubble.color == "blue1" {
        print("blue report ", text)
    }
}

//MARK: -
extension LocalizedStringKey:Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("")
    }
}

struct Names {
    static let testBubbleName = "Red"
    
    private init() {}
}

struct Storagekey {
    static let timerHistoryExists = "timerHistoryExists"
    static let controlFirstTime = "controlFirstTime"
    static let showEachTimeCaffeinatedHint = "showEachTimeCaffeinatedHint"
    static let assistUser = "assistUser"
    static let showDismissHint = "showDismissHint"
    static let hasUserDeletedBubbleNote = "hasUserDeletedBubbleNote"
    static let hasUserDeletedLapNote = "hasUserDeletedLapNote"
    static let hasUserDeletedRecent = "hasUserDeletedRecent"
    static let showUserAssist = "hasUserDeletedLapNote"
    static let showPinnedOnly = "showPinnedOnly"
    static let userFavoritedOnce = "userFavoritedOnce"
    
    private init() {}
}

extension URL {
    static let watchTutorial = URL(string: "https://youtube.com/shorts/6w0wyOZqB4Q?feature=share")
}

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

extension Double {
    static let darkBackground = CGFloat(0.5)
}

extension Notification.Name {
    static let fiveSecondsSignal = Notification.Name("fiveSecondsSignal")
    static let detailViewVisible = Notification.Name("detailViewVisible")
    static let needleTracksLatestSession = Notification.Name("needleTracksLatestSession")
    static let doNotLetNeedleJump = Notification.Name("doNotLetNeedleJump")
    static let sizeNotification = Notification.Name("sizeNotification")
    static let frameNotification = Notification.Name("frameNotification")
    static let didBecomeActive = UIApplication.didBecomeActiveNotification
    
    static let flipTextSignal = Notification.Name("flipTextSignal")
    
    ///kill StartSelayBubble  since sdb.state is now .finished
    static let killDelayBubble = Notification.Name("killSDB")
    
    static let editTimerDuration = Notification.Name("editTimerDuration")
    static let createTimer = Notification.Name("createTimer")
    
    static let killTimer = Notification.Name("killTimer")
    
    static let scrollToTimer = Notification.Name("scrollToTimer")
    
    static let startStopwatch = Notification.Name("startStopwatch")
    
    static let hidePalette = Notification.Name("hidePalette")
} //1 ViewModel

extension Notification {
    static let doNotLetNeedleJump = Notification(name: .doNotLetNeedleJump)
    static let flipTextSignal = Notification(name: .flipTextSignal)
}

public extension Image {
    static let tap = Image(systemName:"hand.tap")
    static let longPress = Image(systemName:"target")
    static let leftSwipe = Image(systemName:"arrow.left")
    static let rightSwipe = Image(systemName:"arrow.right")
    static let scrollToTop = Image(systemName: "arrow.up.and.down.text.horizontal")
    static let info = Image(systemName: "info.circle.fill")
    static let alert = Image(systemName: "exclamationmark.triangle.fill")
    static let roundCheckmark = Image(systemName: "checkmark.circle.fill")
    static let timer = Image(systemName: "timer")
    static let stopwatch = Image(systemName: "stopwatch")
    static let more = Image(systemName: "ellipsis.circle.fill")
    static let reset = Image(systemName: "arrow.counterclockwise")
    static let xmark = Image(systemName: "xmark.square.fill")
    static let lightbulb = Image(systemName: "lightbulb.fill")
    
    static let change = Image(systemName: "arrow.left.arrow.right.square")
    
    static let device = Image(systemName: "iphone.radiowaves.left.and.right")
    static let clock = Image(systemName: "clock")
    
    static let one = Image(systemName: "1.circle.fill")
    static let two = Image(systemName: "2.circle.fill")
    static let three = Image(systemName: "3.circle.fill")
    
    static let closed = Image(systemName: "lock.fill")
    static let opened = Image(systemName: "lock.open.fill")
    
    static let swipe = Image(systemName: "arrow.left")
    static let swipeBidirectional = Image(systemName: "arrow.left")
    static let dragDown = Image(systemName: "arrow.down")
    static let help = Image(systemName: "questionmark.circle")
    
    // MARK: - Info Assetsok
    static let dpv = Image("DurationPicker")
    static let moreOptionsView = Image("MoreOptions")
    
    static let pin = Image(systemName: "pin")
}

public extension Color {
    ///secondary light mode, white dark mode
    static let pauseStickerColor = Color("pauseStickerColor")
    static let pauseStickerFontColor = Color("pauseStickerFontColor")
    static let infoColor = Color("infoColor")
    static let item = Color("itemBackground")
}

extension UserDefaults {
    static func generateRank() -> Int {
        //get rank
        //increase rank by one
        //save rank
        let userDefaults = UserDefaults(suiteName: .appGroupName)!
        var rank = userDefaults.integer(forKey: UserDefaults.Key.rank)
        defer {
            rank += 1
            userDefaults.set(rank, forKey: UserDefaults.Key.rank)
        }
        return rank
    }
    
    static func resetRankGenerator(to value:Int) {
        let userDefaults = UserDefaults(suiteName: String.appGroupName)!
        userDefaults.set(value, forKey: UserDefaults.Key.rank)
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
    var components:Components {
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
        
        return Components(hr: hr, min: min, sec: sec, hundredths: fractionalValue)
    }
    
    var hundredths:Int {
        Int(((self - Float(Int(self))) * 100).rounded(.toNearestOrEven))
    }
    
    ///time components: Hr/Min/Sec/Hundredths converted to String
    var componentsAsString:ComponentsAsString {
        if self == 0 { return .zeroAll }
        
        let components = components
        
        let hundredths = String(format: "%.2d", components.hundredths)
        return ComponentsAsString(hr: String(components.hr),
                                       min: String(components.min),
                                       sec: String(components.sec),
                                       hundredths: hundredths)
    }
    
    var widget:String {
        let components = self.componentsAsString
        
        let hr = (components.hr != "0") ? components.hr + ":" : ""
        let min = (components.min != "0") ? components.min + ":" : (hr > "0") ? "00:" : "0:"
        let sec = components.sec != "0" ? components.sec : "00"
        return hr + min + sec
    }
    
    var widgetFormat:String {
        //minutes 0 if no hours, 00 if there are hours
        let components = self.components
        
        let hr = components.hr != 0 ? String(components.hr) + ":" : ""
        let min = (components.min != 0) ? String(format: "%.2d", components.min)  + ":" : "00:"
        let sec = String(format: "%.2d", components.sec)
        return hr + min + sec
    }
    
    var timeComponentsAbreviatedString:String {
        let components = self.componentsAsString
        
        let hr = (components.hr != "0") ? components.hr + "h" : ""
        let min = (components.min != "0") ? components.min + "m" : ""
        let hundredths = components.hundredths
        let sec = components.sec + "." + hundredths + "s"
        let secResult = sec == "0.00s" ?  "" : sec
        
        var result = hr + " " + min + " " + secResult
        result.trimWhiteSpaceAtTheBeginning()
        return result
    }
    
    //Does not show hundredths or zero seconds e.g. 10.00s -> 10s
    var timerTitle:String {
        let components = self.componentsAsString
        
        let hr = (components.hr != "0") ? components.hr + "h" : ""
        let min = (components.min != "0") ? components.min + "m" : ""
        let sec = components.sec != "0" ? components.sec + "s" : ""
        var result = hr + " " + min + " " + sec
        result.trimWhiteSpaceAtTheBeginning()
        return result
    }
    
    ///time components: hr, min, sec, hundredths (displayed by the bubble)
    struct Components {
        let hr:Int
        let min:Int
        let sec:Int
        let hundredths:Int
        
        static let zeroAll = Components(hr: 0, min: 0, sec: 0, hundredths: 0)
    }
    
    ///time components: hr, min, sec, hundredths (displayed by the bubble). e.g. "12 hr 34 min 25 sec"
    struct ComponentsAsString:Encodable, Decodable, Equatable {
        let hr:String
        let min:String
        let sec:String
        let hundredths:String
        
        static let zeroAll = ComponentsAsString(hr: "0", min: "0", sec: "0", hundredths: "00")
    }
}

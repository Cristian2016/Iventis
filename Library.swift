//
//  Library.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.01.2023.
//

import SwiftUI

extension Color {
    static let pauseStickerColor = Color("pauseStickerColor")
    static let pauseStickerFontColor = Color("pauseStickerFontColor")
}

public extension UserInterfaceSizeClass {
    var isRegular:Bool { self == .regular ? true : false }
}

///various constants and values
public struct Global {
    static let longPressLatency = Double(0.3) //seconds
    
    //bubbleCell size
    static let dic:[CGFloat:CGFloat] = [ /* 12mini */728:140, /* 8 */667:150,  /* ipdo */568:125,  /* 13 pro max */926:150,  /* 13 pro */844:147,  /* 11 pro max */896:150, 812:130,  /* 8max */736:167]
    
    static let circleDiameter:CGFloat = {
        print(UIScreen.main.bounds.height)
        return dic[UIScreen.size.height] ?? 140
    }()
    
    struct FontSize {
        static let help = CGFloat(30)
    }
}

public extension Float {
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

extension Notification.Name {
    static let sizeNotification = Notification.Name("sizeNotification")
    static let frameNotification = Notification.Name("frameNotification")
}

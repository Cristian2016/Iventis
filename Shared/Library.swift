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

struct Geometry {
    
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

extension Color {
    //row 1
    static let bubbleMint = Color.red
    static let bubbleSlateBlue = Color.red
    static let bubbleSourCherry = Color.red
    
    //row 2
    static let bubbleSilver = Color.red
    static let bubbleUltramarine = Color.red
    static let bubbleLemon = Color.red
    
    //row 3
    static let bubbleRed = Color.red
    static let bubbleSky = Color.red
    static let bubbleBubbleGum = Color.red
    
    //row 4
    static let bubbleGreen = Color.red
    static let bubbleCoffee = Color.red
    static let bubbleMagenta = Color.red
    
    //row 5
    static let bubblePurple = Color.red
    static let bubbleOrange = Color.red
    static let bubbleChocolate = Color.red
    
    //row 6
    static let bubbleAqua = Color.red
    static let bubbleByzantium = Color.red
    static let bubbleRose = Color.red
}

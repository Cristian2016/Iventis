//
//  Colors.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import SwiftUI

extension Color {
    static let friendlyNames = [
        "sourCherry":"Sour Cherry",
        "mint1" : "Mint",
        "slateBlue" : "Slate Blue",
        "gray1" : "Gray",
        "ultramarine" : "Ultramarine",
        "yellow1" : "Yellow",
        "red1" : "Red",
        "blue1" : "Blue",
        "bubbleGum" : "Bubblegum",
        "green1" : "Green",
        "black1" : "Black",
        "magenta1" : "Magenta",
        "purple1" : "Purple",
        "orange1" : "Orange",
        "aqua" : "Aqua",
        "byzantium" : "Byzantium",
        "pink1" : "Pink",
        "aubergine" : "Aubergine",
        "cayenne" : "Cayenne",
        "mocha" : "Mocha",
        "brown1" : "Brown",
        "darkGreen" : "Dark Green"
    ]
    
    static func friendlyBubbleColorName(for bubbleColorName:String?) -> String {
        guard
            let bubbleColorName = bubbleColorName,
            let colorName = friendlyNames[bubbleColorName]
        else { return "red" }
        
        return colorName
    }
    
    struct Bicolor:Hashable, Identifiable {
        let description:String
        var color:Color { Color(description)}
        var id:String { description }
    }
    
    ///same order in Palette and MoreOptionsView. Both views are reading from this array
    static let bicolors = [
        Bubble.orange, Bubble.brown, Bubble.yellow,
        Bubble.green, Bubble.mint, Bubble.ultramarine,
        Bubble.slateBlue, Bubble.sourCherry, Bubble.red,
        Bubble.gray, Bubble.black,
        Bubble.blue, Bubble.bubbleGum, Bubble.cayenne,
        Bubble.byzantium,  Bubble.purple, Bubble.aqua,
        Bubble.pink, Bubble.aubergine, Bubble.magenta
    ]
    
    ///to use with Grid and GridRow
    static let paletteBicolors = [
        [Bubble.orange, Bubble.brown, Bubble.yellow, Bubble.green],
        [Bubble.mint, Bubble.ultramarine, Bubble.slateBlue, Bubble.sourCherry],
        [Bubble.red,Bubble.gray, Bubble.black, Bubble.blue],
        [Bubble.bubbleGum, Bubble.cayenne, Bubble.byzantium,  Bubble.purple],
        [Bubble.aqua, Bubble.pink, Bubble.aubergine, Bubble.magenta]
    ]
    
    ///⚠️ struct Color.Bubble vs CoreData class Bubble
    struct Bubble {
        ///it will not show up in Color.bicolors
        static let clearButtonRed = Bicolor(description: Name.clearButtonRed.rawValue)
        
        //row 1
        static let cayenne = Bicolor(description: Name.cayenne.rawValue)
        static let aubergine = Bicolor(description: Name.aubergine.rawValue)
        
        static let mint = Bicolor(description: Name.mint1.rawValue)
        static let slateBlue = Bicolor(description: Name.slateBlue.rawValue)
        static let sourCherry = Bicolor(description: Name.sourCherry.rawValue)
        
        //row 2
        static let gray = Bicolor(description: Name.gray1.rawValue)
        static let ultramarine = Bicolor(description: Name.ultramarine.rawValue)
        static let yellow = Bicolor(description: Name.yellow1.rawValue)
        
        //row 3
        static let red = Bicolor(description: Name.red1.rawValue)
        static let blue = Bicolor(description: Name.blue1.rawValue)
        static let bubbleGum = Bicolor(description: Name.bubbleGum.rawValue)
        
        //row 4
        static let green = Bicolor(description: Name.green1.rawValue)
        static let black = Bicolor(description: Name.black1.rawValue)
        static let magenta = Bicolor(description: Name.magenta1.rawValue)
        
        //row 5
        static let purple = Bicolor(description: Name.purple1.rawValue)
        static let orange = Bicolor(description: Name.orange1.rawValue)
        
        //row 6
        static let aqua = Bicolor(description: Name.aqua.rawValue)
        static let byzantium = Bicolor(description: Name.byzantium.rawValue)
        static let pink = Bicolor(description: Name.pink1.rawValue)
        static let mocha = Bicolor(description: Name.mocha.rawValue)
        static let brown = Bicolor(description: Name.brown1.rawValue)
        
        //clear
        static let clear = Bicolor(description: Name.clear.rawValue)
    }
    
    enum Name:String {
        case mint1
        case slateBlue
        case sourCherry
        
        case gray1
        case ultramarine
        case yellow1
        
        case red1
        case blue1
        case bubbleGum
        
        case green1
        case black1
        case magenta1
        
        case purple1
        case orange1
        
        case aqua
        case byzantium
        case pink1
        
        case cayenne
        case aubergine
        case mocha
        case brown1
        
        case clear
        
        case clearButtonRed
    }
}

extension Color {
    static func bubbleColor(forName bubbleColorName:String?) -> Color {
        return (bicolors.filter { $0.description == bubbleColorName }.first ?? Color.Bubble.clear).color
    }
    
    static func bicolor(forName bubbleColorName:String?) -> Bicolor {
        (bicolors.filter { $0.description == bubbleColorName }.first ?? Color.Bubble.clear)
    }
    
    static let emojis = ["yellow1":"🟨",
                         "red1":"🟥",
                         "ultramarine":"🟦",
                         "green1":"🟩",
                         "orange1":"🟧",
                         "purple1":"🟪",
                         "black1":"⬛️",
                         "gray1":"⬜️"
    ]
    
    static func emoji(for colorName:String?) -> String {
        guard let colorName = colorName else { return String() }
        return emojis[colorName.lowercased()] ?? String()
    }
}

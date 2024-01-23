//
//  All Colors.swift
//  Eventify
//
//  Created by Cristian Lapusan on 27.01.2024.
//

import SwiftUI

struct Bicolor:Hashable, Identifiable {
    let description:String
    let dark:Color
    let light:Color
    var id:String { description }
}

enum Dark:String {
    case mint
    case slateBlue
    case sourCherry
    
    case gray
    case ultramarine
    case yellow
    
    case red
    case blue
    case bubbleGum
    
    case green
    case black
    case magenta
    
    case purple
    case orange
    
    case aqua
    case byzantium
    case pink
    
    case cayenne
    case aubergine
    case brown
    
    case clear
    
    case clearButtonRed
}

//
//  Colors.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import SwiftUI

extension Color {
    struct Three {
        let description:String
        let hr:Color //light
        let min:Color //medium
        let sec:Color //intense
    }
    
    struct Bubbles {
        //row 1
        static let mint = Three(description: "mint", hr:Color(#colorLiteral(red: 0, green: 0.999099791, blue: 0.8100017905, alpha: 1)), min: Color(#colorLiteral(red: 0, green: 0.9633229375, blue: 0.7392000556, alpha: 1)), sec: Color(#colorLiteral(red: 0.03296933323, green: 0.907636106, blue: 0.6436124444, alpha: 1)))
        static let slateBlue = Three(description: "slateBlue", hr: Color(#colorLiteral(red: 0.6250013709, green: 0.643127501, blue: 0.9769508243, alpha: 1)), min: Color(#colorLiteral(red: 0.4915649891, green: 0.5337389708, blue: 0.9743657708, alpha: 1)), sec: Color(#colorLiteral(red: 0.4223788977, green: 0.4790267348, blue: 0.9767156243, alpha: 1)))
        static let sourCherry = Three(description: "sourCherry", hr: Color(#colorLiteral(red: 0.9564458728, green: 0.06965851039, blue: 0.4674955606, alpha: 1)), min: Color(#colorLiteral(red: 0.8373516798, green: 0.06469952315, blue: 0.41300717, alpha: 1)), sec: Color(#colorLiteral(red: 0.7311170697, green: 0.05191928893, blue: 0.3622907996, alpha: 1)))
        
        //row 2
        static let silver = Three(description: "silver", hr: Color(#colorLiteral(red: 0.7019609809, green: 0.7019608617, blue: 0.7019608617, alpha: 1)), min: Color(#colorLiteral(red: 0.6000001431, green: 0.6000000834, blue: 0.6000000834, alpha: 1)), sec: Color(#colorLiteral(red: 0.5333333611, green: 0.5333333611, blue: 0.5333333611, alpha: 1)))
        static let ultramarine = Three(description: "ultramarine", hr: Color(#colorLiteral(red: 0.2087187171, green: 0.6593058705, blue: 0.9996295571, alpha: 1)), min: Color(#colorLiteral(red: 0.06983245909, green: 0.548355639, blue: 1, alpha: 1)), sec: Color(#colorLiteral(red: 0, green: 0.3887374103, blue: 0.9969165921, alpha: 1)))
        static let lemon = Three(description: "lemon", hr: Color(#colorLiteral(red: 0.9833838344, green: 0.8914203644, blue: 0, alpha: 1)), min: Color(#colorLiteral(red: 0.9715102315, green: 0.8551748395, blue: 0, alpha: 1)), sec: Color(#colorLiteral(red: 0.9762087464, green: 0.8017882705, blue: 0.01509543974, alpha: 1)))
        
        //row 3
        static let red = Three(description: "red", hr: Color(#colorLiteral(red: 0.9993676543, green: 0.515832901, blue: 0.4665791392, alpha: 1)), min: Color(#colorLiteral(red: 0.9752207398, green: 0.301009059, blue: 0.2363895774, alpha: 1)), sec: Color(#colorLiteral(red: 0.9948095679, green: 0.04287932068, blue: 0.01928717084, alpha: 1)))
        static let sky = Three(description: "sky", hr: Color(#colorLiteral(red: 0.3429786265, green: 0.8417432904, blue: 0.9890826344, alpha: 1)), min: Color(#colorLiteral(red: 0.09564081579, green: 0.8035189509, blue: 0.9921918511, alpha: 1)), sec: Color(#colorLiteral(red: 0, green: 0.7678601742, blue: 0.9985458255, alpha: 1)))
        static let bubbleGum = Three(description: "bubbleGum", hr: Color(#colorLiteral(red: 0.9885047078, green: 0.6262013316, blue: 0.9807611108, alpha: 1)), min: Color(#colorLiteral(red: 0.9893129468, green: 0.4895346761, blue: 0.9776270986, alpha: 1)), sec: Color(#colorLiteral(red: 0.9892597795, green: 0.3731681108, blue: 0.9725615382, alpha: 1)))
        
        //row 4
        static let green = Three(description: "green", hr: Color(#colorLiteral(red: 0.1198918894, green: 0.8718696237, blue: 0.155010134, alpha: 1)), min: Color(#colorLiteral(red: 0.1077821925, green: 0.7843493819, blue: 0.1306060255, alpha: 1)), sec: Color(#colorLiteral(red: 0.08472224325, green: 0.6849253774, blue: 0.1049573496, alpha: 1)))
        static let coffee = Three(description: "coffee", hr: Color(#colorLiteral(red: 0.4745098948, green: 0.4745098948, blue: 0.4745098948, alpha: 1)), min: Color(#colorLiteral(red: 0.2588235736, green: 0.2588236034, blue: 0.2588235736, alpha: 1)), sec: Color(#colorLiteral(red: 0.1294117868, green: 0.1294117868, blue: 0.1294117868, alpha: 1)))
        static let magenta = Three(description: "magenta", hr: Color(#colorLiteral(red: 0.9885047078, green: 0.6262013316, blue: 0.9807611108, alpha: 1)), min: Color(#colorLiteral(red: 0.9893129468, green: 0.4895346761, blue: 0.9776270986, alpha: 1)), sec: Color(#colorLiteral(red: 0.9892597795, green: 0.3731681108, blue: 0.9725615382, alpha: 1)))
        
        //row 5
        static let purple = Three(description: "purple", hr: Color(#colorLiteral(red: 0.7857518196, green: 0.4235508442, blue: 0.9829426408, alpha: 1)), min: Color(#colorLiteral(red: 0.72523278, green: 0.255584538, blue: 0.983091414, alpha: 1)), sec: Color(#colorLiteral(red: 0.6532509923, green: 0.1514221728, blue: 0.9810264707, alpha: 1)))
        static let orange = Three(description: "orange", hr: Color(#colorLiteral(red: 0.9909816384, green: 0.5975839496, blue: 0.28533867, alpha: 1)), min: Color(#colorLiteral(red: 0.9978527427, green: 0.4815151691, blue: 0.0934284851, alpha: 1)), sec: Color(#colorLiteral(red: 0.9940095544, green: 0.3513067961, blue: 0, alpha: 1)))
        static let chocolate = Three(description: "chocolate", hr: Color(#colorLiteral(red: 0.4977113605, green: 0.3385047317, blue: 0.24831599, alpha: 1)), min: Color(#colorLiteral(red: 0.4361367822, green: 0.2961739898, blue: 0.2281888127, alpha: 1)), sec: Color(#colorLiteral(red: 0.3970826566, green: 0.2525862753, blue: 0.2026238441, alpha: 1)))
        
        //row 6
        static let aqua = Three(description: "aqua", hr: Color(#colorLiteral(red: 0, green: 0.9749670625, blue: 1, alpha: 1)), min: Color(#colorLiteral(red: 0.003376292763, green: 0.9073271751, blue: 0.9472805858, alpha: 1)), sec: Color(#colorLiteral(red: 0, green: 0.855682075, blue: 0.8874734044, alpha: 1)))
        static let byzantium = Three(description: "byzantium", hr: Color(#colorLiteral(red: 0.6075749397, green: 0.2570540309, blue: 0.5635319352, alpha: 1)), min: Color(#colorLiteral(red: 0.5355527997, green: 0.2330842912, blue: 0.4949119091, alpha: 1)), sec: Color(#colorLiteral(red: 0.4615408778, green: 0.1781537533, blue: 0.4272875786, alpha: 1)))
        static let rose = Three(description: "rose", hr: Color(#colorLiteral(red: 0.9601778388, green: 0.5991181135, blue: 0.6990267038, alpha: 1)), min: Color(#colorLiteral(red: 0.9777489305, green: 0.4076962173, blue: 0.5763365626, alpha: 1)), sec: Color(#colorLiteral(red: 0.9909614921, green: 0.2357916832, blue: 0.4794922471, alpha: 1)))
    }
    
    var name:String {
        return description
    }
    
    enum Name:String {
        case mint
        case slateBlue
        case sourCherry
        
        case silver
        case ultramarine
        case lemon
        
        case red
        case sky
        case bubbleGum
        
        case green
        case coffee
        case magenta
        
        case purple
        case orange
        case chocolate
        
        case aqua
        case byzantium
        case rose
    }
}

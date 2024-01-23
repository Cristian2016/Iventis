//
//  Pair+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 23.04.2022.
//
//

import Foundation
import CoreData


public class Pair: NSManagedObject {
    enum DurationComputed {
        case atPause
        case atCloseSession
    }
    
    var note_:String {
        get { note ?? "" }
        set { note = newValue }
    }
    
    ///runs on background thread. it computes at 1.pause or 2.closeSession. closeSession means substracting 0.5 seconds from the duration
    func computeDuration(_ durationComputed:DurationComputed) {
        guard let pause = pause else { fatalError() }
        
        //set duration
        let duration:Float
        switch durationComputed {
            case .atPause:
                duration = Float(pause.timeIntervalSince(start ?? Date()))
            case .atCloseSession:
                duration = Float(pause.timeIntervalSince(start ?? Date()) - Global.longPressLatency)
        }
        
        //convert duration.timeComponentsAsStrings to Data using JSONEncoder
        let componentStrings = duration.componentsAsString
        let data = try? JSONEncoder().encode(componentStrings)
        
        self.duration = duration
        durationAsStrings = data
    }
}

extension Pair : Identifiable { }

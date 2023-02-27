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
    
    deinit {
//        print("pair deinit")
    }
    
    enum DurationComputed {
        case atPause
        case atEndSession
    }
    
    var note_:String {
        get { note ?? "" }
        set { note = newValue }
    }
    
    ///runs on background thread. it computes at 1.pause or 2.endSession. endSession means substracting 0.5 seconds from the duration
    func computeDuration(_ durationComputed:DurationComputed, completion: @escaping () -> ()) {
        
        DispatchQueue.global().async {
            
            //make sure duration can be computed
            guard let start = self.start, let pause = self.pause else { fatalError() }
            
            //set duration
            let duration:Float
            switch durationComputed {
                case .atPause:
                    duration = Float(pause.timeIntervalSince(start))
                case .atEndSession:
                    duration = Float(pause.timeIntervalSince(start) - Global.longPressLatency)
            }
            
            //convert duration.timeComponentsAsStrings to Data using JSONEncoder
            let componentStrings = duration.timeComponentsAsStrings
            let data = try? JSONEncoder().encode(componentStrings)
            
            self.managedObjectContext?.perform {
                self.duration = duration
                self.durationAsStrings = data
            }
            
            DispatchQueue.main.async { completion() }
        }
    }
}

extension Pair : Identifiable { }

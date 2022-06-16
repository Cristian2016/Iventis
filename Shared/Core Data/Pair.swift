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
    
    struct TimeComponentsAsString:Codable {
        let hr:String
        let min:String
        let sec:String
        let cents:String //hundredths :)
    }
    
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
    func computeDuration(_ durationComputed:DurationComputed, completion: @escaping (Float, Data) -> ()) {

        DispatchQueue.global().async {
            
            //make sure Pair duration can be computed
            //make sure pauseDate is set, otherwise duration cannot be computed
            guard let pause = self.pause else { fatalError() }
            
            if let start = self.start {
                let duration:Float
                switch durationComputed {
                    case .atPause:
                        duration = Float(pause.timeIntervalSince(start))
                    case .atEndSession:
                        duration = Float(pause.timeIntervalSince(start) - Global.longPressLatency)
                }
                
                //convert duration.timeComponentsAsStrings to raw data using JSONEncoder
                let componentStrings = duration.timeComponentsAsStrings
                let data = try? JSONEncoder().encode(componentStrings)
                
                DispatchQueue.main.async {
                    completion(duration, data!)
                    //⚠️ Session computes its duration after pair computes its duration and then session saves context. No need to save context here since session saves it anyway
                }
            }
        }
    }
}

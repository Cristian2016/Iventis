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
        case pause
        case endSession
    }
    
    func computeDuration(_ durationComputed:DurationComputed) {
        guard let pause = pause else { fatalError() }
        
        switch durationComputed {
            case .pause:
               
                duration = Float(pause.timeIntervalSince(start))
//                print("pause \(duration)")
            case .endSession:
               
                duration = Float(pause.timeIntervalSince(start) - 0.5)
//                print("session ended \(duration)")
        }
    }
}

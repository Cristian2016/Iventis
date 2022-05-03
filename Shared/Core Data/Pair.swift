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
    
//    func computePairDuration(_ durationComputed:DurationComputed) {
//        guard let pause = pause else { fatalError() }
//        if let start = start {
//            switch durationComputed {
//                case .pause:
//                    duration = Float(pause.timeIntervalSince(start))
//                case .endSession:
//                    duration = Float(pause.timeIntervalSince(start) - 0.5)
//            }
//        }
//    }
    
    func pairDuration(_ durationComputed:DurationComputed, completion: @escaping (Float) -> ()) {
        DispatchQueue.global().async {
            guard let pause = self.pause else { fatalError() }
            if let start = self.start {
                let value:Float
                switch durationComputed {
                    case .pause:
                        value = Float(pause.timeIntervalSince(start))
                    case .endSession:
                        value = Float(pause.timeIntervalSince(start) - 0.5)
                }
                DispatchQueue.main.async {
                    completion(value)
                }
            }
        }
    }
}

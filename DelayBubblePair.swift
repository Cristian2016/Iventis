//
//  SDBPair+CoreDataClass.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//

import Foundation
import CoreData


public class DelayBubblePair: NSManagedObject {
    func computeDuration() -> Float {
        Float(pause?.timeIntervalSince(self.start) ?? 0)
    }
}

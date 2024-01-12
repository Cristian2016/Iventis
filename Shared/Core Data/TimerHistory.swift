//
//  TimerHistory+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.05.2023.
//
//

import Foundation
import CoreData


public class TimerHistory: NSManagedObject {
    var allDurations:[TimerDuration] {
        timerDurations?.array as? [TimerDuration] ?? []
    }
}
